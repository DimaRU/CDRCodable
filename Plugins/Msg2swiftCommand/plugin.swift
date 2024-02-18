import PackagePlugin
import Foundation

@main
struct Msg2swiftCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let msg2swiftTool = try context.tool(named: "msg2swift").path
        var argExtractor = ArgumentExtractor(arguments)

        let targetNames = argExtractor.extractOption(named: "target")
        var runArguments = argExtractor.remainingArguments
        if !(arguments.contains("-o") || arguments.contains("--output-directory")) {
            let targets = targetNames.isEmpty
            ? context.package.targets
            : try context.package.targets(named: targetNames)
            
            for target in targets {
                guard let target = target as? SourceModuleTarget else { continue }
                runArguments.append("--output-directory")
                runArguments.append(target.directory.string)
                break
            }
        }

        let process = try Process.run(URL(fileURLWithPath: msg2swiftTool.string), arguments: runArguments)
        process.waitUntilExit()
        
        guard
            process.terminationReason == .exit,
            process.terminationStatus == 0
        else {
            let problem = "\(process.terminationReason):\(process.terminationStatus)"
            Diagnostics.error("msg2swift invocation failed: \(problem)")
            return
        }
    }
}
