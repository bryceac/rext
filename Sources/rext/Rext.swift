import Foundation
import ArgumentParser

struct Rext: ParsableCommand {

    // give program an overview
    static let configuration = CommandConfiguration(abstract: "quickly renames all files with a specified extension with another specified extension")
    
    // specify options, allowing use of short and long flags on each option
    @Option(name: .shortAndLong, default: ".", help: "Specifies the directory to go through (must enclose in \"\", to be recognized).") var dir: String
    @Option(name: .shortAndLong, help: "Specifies the file extension to be replaced.") var ext: String
    @Option(name: .shortAndLong, help: "Specifies the new file extension") var output: String
    @Option(name: .shortAndLong, default: false, help: "determines whether or not subdirectories will be affected. Default is false, which only affects specified directory.") var recursive: Bool

    
    // calculated property, to generate directory path
    var directory: URL {
        let FILE_MANAGER = FileManager.default
        var baseDirectory: URL?
        var folder: URL!

        // determine if directory contain relative shorthands and execute code depending on results
        switch dir {
            case let str where str.contains("~"):
                let HOME_DIRECTORY = FILE_MANAGER.homeDirectoryForCurrentUser
                baseDirectory = HOME_DIRECTORY

                // determine if subdirectory is specified, by checking for slashes
                if dir.contains("/") {
                    let DIRECTORY_COMPONENTS = dir.components(separatedBy:"/")
                    folder = baseDirectory!

                    // create URL object that directs to specified path.
                    for pathComponent in DIRECTORY_COMPONENTS {
                        guard pathComponent != DIRECTORY_COMPONENTS.first! else { continue }

                        folder = folder.appendingPathComponent(pathComponent)
                    }
                }
            case let str where str.contains("."):
                let CURRENT_DIRECTORY = URL(string: FILE_MANAGER.currentDirectoryPath)
                baseDirectory = CURRENT_DIRECTORY

                if dir.contains("/") {
                    let DIRECTORY_COMPONENTS = dir.components(separatedBy:"/")
                    folder = baseDirectory!
                    
                    for pathComponent in DIRECTORY_COMPONENTS {
                        guard pathComponent != DIRECTORY_COMPONENTS.first! else { continue }

                        folder = folder.appendingPathComponent(pathComponent)
                    }
                }
            default: ()
        }

        // return specified path
        return folder
    } // end calculated property

    // the replace function move files with a particular extension to the new extension
    func replace(extension ext: String, with newExt: String, in directory: URL, recursive: Bool = false) {
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
        replace(extension: ext, with: output, in: directory, recursive: recursive)
    }
}
