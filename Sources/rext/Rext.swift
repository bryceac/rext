import Foundation
import ArgumentParser

struct Rext: ParsableCommand {

    // give program an overview
    static let configuration = CommandConfiguration(abstract: "quickly renames all files with a specified extension with another specified extension")
    
    // specify options and flags, allowing use of short and long flags on each option and flag
    @Option(name: .shortAndLong, default: ".", help: "Specifies the directory to go through.") var dir: String
    @Option(name: .shortAndLong, help: "Specifies the file extension to be replaced.") var ext: String?
    @Option(name: .shortAndLong, help: "Specifies the new file extension.") var newExtension: String?
    @Flag(name: .shortAndLong, help: "recursively change extensions.") var recursive: Bool
    @Flag(name: .shortAndLong, help: "display status while renaming files.") var verbose: Bool

    
    // calculated property, to generate directory path
    var directory: URL {
        
        // return specified path, subsituting shorthands for proper directories
        return URL(fileURLWithPath: dir.standardizingPath)
    } // end calculated property

    // the replace function move files with a particular extension to the new extension
    func replace(extension ext: String?, with newExt: String?, in directory: URL, recursive: Bool = false) {
        guard let ext = ext, let newExt = newExt else {
            print("Please provide both extension and new extension.\r\n\r\nTo find out how, issue command again with either -h or --help flags.")
            return
        }

        let FILE_MANAGER = FileManager.default

        // attempt to grab list of files and folders
        guard let CONTENTS = try? FILE_MANAGER.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            fatalError("cannot read directory!")
        }

        // check if user wanted recursion and execute appropriate code
        if !recursive {
            for item in CONTENTS {

                // make sure path is not a directory and check extension
                guard !item.hasDirectoryPath && item.pathExtension == ext else { continue }

                let FILE_NAME = item.deletingPathExtension().lastPathComponent

                let NEW_URL = directory.appendingPathComponent(FILE_NAME).appendingPathExtension(newExt)
                
                if verbose {
                    print("renaming \(item.path) to \(NEW_URL.path)")
                }

                // attempt to move file
                do {
                    try FILE_MANAGER.moveItem(at: item, to: NEW_URL)
                } catch {
                    print("Cannot rename \(item.lastPathComponent).")
                }
                
            }
        } else {
            for item in CONTENTS {

                if item.hasDirectoryPath {

                    // call a new instance of self if item is a directory
                    replace(extension: ext, with: newExt, in: item, recursive: recursive)
                } else {
                    guard item.pathExtension == ext else { continue }

                    let FILE_NAME = item.deletingPathExtension().lastPathComponent

                    let NEW_URL = directory.appendingPathComponent(FILE_NAME).appendingPathExtension(newExt)
                    
                    if verbose {
                        print("renaming \(item.path) to \(NEW_URL.path)")
                    }

                    do {
                        try FILE_MANAGER.moveItem(at: item, to: NEW_URL)
                    } catch {
                        print("Cannot rename \(item.lastPathComponent).")
                    }
                }
            }
        }
    } // end function

    // function that is run when command is called
    func run() {
        replace(extension: ext, with: newExtension, in: directory, recursive: recursive)        
    }
}
