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

    private static getVariableName(prefix: string, outputName: string){
        return isNullOrUndefined(prefix) 
            ? outputName
            : prefix + outputName;
    }

    private static mapOutputsToVariables(outputFilePath: string, prefix: string, mapSensitiveOutputsAsSecrets: boolean) {
        
        let outputsData = fs.readFileSync(outputFilePath, 'utf8');

        console.log("Mapping outputs...")
        
        let outputs = JSON.parse(outputsData);

        for (var output in outputs) {
            if (outputs.hasOwnProperty(output)) {
                
                var variableName = this.getVariableName(prefix, output);

                var variableValue = outputs[output].value;

                var isSecret = mapSensitiveOutputsAsSecrets === true && outputs[output].sensitive === true;
                
                console.log("- " + variableName);

                tl.setVariable(variableName, variableValue, isSecret);
            }
        }
    }

    public static async run() {
        try {
            let variablePrefix: string = tl.getInput("variablePrefix");
            let workingDirectory: string = tl.getInput("workingDirectory");
            let pathToTerraform: string = tl.getInput("pathToTerraform");
            let mapSensitiveOutputsAsSecrets: boolean = tl.getInput("mapSensitiveOutputsAsSecrets");
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

            if (exitCode !== 0) {
                throw <Error>{message: "Terraform execution returned '"+exitCode+"' exit code."}
            }

            this.mapOutputsToVariables(outputFilePath, variablePrefix, mapSensitiveOutputsAsSecrets);

            tl.setResult(tl.TaskResult.Succeeded,"");
        }
        catch (err) {
            tl.setResult(tl.TaskResult.Failed, err.message);
        }
    }
}

terraformoutputstask.run();
