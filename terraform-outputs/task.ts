import tl = require('vsts-task-lib/task');
import tr = require('vsts-task-lib/toolrunner');
import fs = require('fs');
import os = require("os");
import path = require("path");
import { isNullOrUndefined } from 'util';
import uuidV4 = require('uuid/v4');

export class terraformoutputstask {

    private static getTerraformPath(pathToTerraform:string) {
        let terraformBinary = (os.type() != "Windows_NT")
            ? "terraform"
            : "terraform.exe";

        let terraformPath = isNullOrUndefined(pathToTerraform)
            ? terraformBinary
            : path.join(pathToTerraform, terraformBinary);
        
        return terraformPath;
    }

    private static mapOutputsToVariables(outputFilePath:string){
        var outputs = JSON.parse(fs.readFileSync(outputFilePath, 'utf8'));

        for (var output in outputs) {
            if( outputs.hasOwnProperty(output) ) {
                console.log("variable name: '" + output + "'")
                console.log("variable value: '" + outputs[output].value + "'")
                
                tl.setVariable(output, outputs[output].value);
            } 
        } 
    }

    public static async run() {
        try {
            let pathToTerraform: string = tl.getInput("pathToTerraform");
            
            let workingDirectory: string = tl.getInput("workingDirectory");

            let outputFilePath = path.join(pathToTerraform, uuidV4() + '.out');

            let terraformPath = this.getTerraformPath(pathToTerraform);

            let terraformArguments = "output -json > " + outputFilePath;

            console.log("Output file path: '" + outputFilePath + "'");
            console.log("Terraform path: '" + terraformPath + "'")
            console.log("Terraform scripts path: '" + pathToTerraform + "'")
            console.log("Arguments: '" + terraformArguments + "'")

            let tool = (os.type() != "Windows_NT")
                ? tl.tool(tl.which("bash", true)).arg(terraformPath + " " + terraformArguments)
                : tl.tool(tl.which(terraformPath, true)).arg(terraformArguments);

            let options = <tr.IExecOptions><unknown>{
                cwd: workingDirectory,
                failOnStdErr: false,
                errStream: process.stdout,
                outStream: process.stdout,
                ignoreReturnCode: true
            };

            // Run bash.
            let exitCode: number = await tool.exec(options);

            let result = tl.TaskResult.Succeeded;

            // Fail on exit code.
            if (exitCode !== 0) {
                tl.error(tl.loc('JS_ExitCode', exitCode));
                result = tl.TaskResult.Failed;
            }

            this.mapOutputsToVariables(outputFilePath); 

        }
        catch (err) {
            tl.setResult(tl.TaskResult.Failed, err.message);
        }
    }
}

terraformoutputstask.run();