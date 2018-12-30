import tl = require('vsts-task-lib/task');
import tr = require('vsts-task-lib/toolrunner');
import fs = require('fs');
import os = require("os");
import path = require("path");
import { isNullOrUndefined } from 'util';
import uuidV4 = require('uuid/v4');

export class terraformoutputstask {

    private static getTerraformPath(pathToTerraform: string) {
        let terraformBinary = (os.type() != "Windows_NT")
            ? "terraform"
            : "terraform.exe";

        let terraformPath = isNullOrUndefined(pathToTerraform)
            ? terraformBinary
            : path.join(pathToTerraform, terraformBinary);

        return terraformPath;
    }

    private static mapOutputsToVariables(outputFilePath: string) {
        let outputsData = fs.readFileSync(outputFilePath, 'utf8');

        console.log("Outputs data: "+outputsData);
        
        let outputs = JSON.parse(outputsData);

        for (var output in outputs) {
            if (outputs.hasOwnProperty(output)) {
                console.log("variable name: '" + output + "'")
                console.log("variable value: '" + outputs[output].value + "'")

                tl.setVariable(output, outputs[output].value);
            }
        }
    }

    public static async run() {
        try {
            let workingDirectory: string = tl.getInput("workingDirectory");
            let pathToTerraform: string = tl.getInput("pathToTerraform");
            let terraformPath = this.getTerraformPath(pathToTerraform);

            let outputFilePath = path.join(workingDirectory, uuidV4() + '.out');
            
            console.log("Output file path: '" + outputFilePath + "'");
            console.log("Terraform path: '" + terraformPath + "'")
            console.log("Terraform scripts path: '" + pathToTerraform + "'")

            let tool = tl.tool(tl.which(terraformPath, true)).arg("output").arg("-json");
            
            let options = <tr.IExecOptions><unknown>{
                cwd: workingDirectory,
                errStream: process.stdout,
                outStream: process.stdout,
                failOnStdErr: false,
                ignoreReturnCode: true,
                silent: true,
                windowsVerbatimArguments: false
            };

            tool.on('stdout', (out) => {
                fs.writeFileSync(outputFilePath, out, { encoding: 'utf8', flag: 'a'});
            });

            let exitCode: number = await tool.exec(options);

            let result = tl.TaskResult.Succeeded;

            if (exitCode !== 0) {
                result = tl.TaskResult.Failed;
            } else {
                this.mapOutputsToVariables(outputFilePath);
            }

            tl.setResult(result,exitCode.toString());
        }
        catch (err) {
            tl.setResult(tl.TaskResult.Failed, err.message);
        }
    }
}

terraformoutputstask.run();
