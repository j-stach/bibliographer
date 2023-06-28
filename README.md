# bibliographer (WIP)
Bibliographer is a command line tool for effortlessly reformatting academic bibliographies from one reference style to another. <br>
Future versions will be able to reformat entire essays, including in-text citations. <br>
### Work in progress
**The current version is not functional and should not be used. However, feel free to browse the source code for ideas, and feel free to offer suggestions. New features will not be considered until the core functionality is established.** <br>

### Note: This is a personal portfolio project, not a professional tool. I intend to make it the best it can be, but make no guarantees of its effectiveness or functionality. If you would like to use it you are welcome, but I recommend reading this documentation thoroughly before setting it up on your device. Additionally, consult the --help documentation and test the script on a sample bibliography before attempting to use it on an actual file.
Any bugs or difficulty you encounter can be reported to this github repository by submitting an issue, but please read the current list of issues before submitting a request. You can also send me an email at surefire93@proton.me to report an issue; please include "Bibliographer" in the subject line and attach the before and after files to the email body if you are able. <br>

## Requirements
As it stands, the only dependency for this tool is Perl 5, but as features are added other modules may need to be added with CPAN. <br>
On Unix-like systems such as Linux and MacOS this can be handled by the unix\_setup.pl script, which will check for the required modules and add them if necessary. <br>
For other operating systems such as Windows, or for Unix-like systems that have a nonstandard file or shell configuration, these modules will have to be added manually until a setup script can be created that is able to configure these systems automatically. <br>

**Perl module dependencies are listed below:** <br>
- None currently

## Setup
Setup this tool by first installing Perl 5.14 or later if your computer does not already include it. <br>
Bibliographer relies on several modules that are included with the core Perl 5 distribution so make sure the version of Perl you download contains the standard features. 
If you are uncertain, Strawberry Perl is a good choice. <br>
Next, clone this repository in your preferred location. 
It does not matter to the script where you place it, as the setup script will create an alias for the program that enables you to call it from any directory without specifying a file path. See the steps below for more information. <br>

### For Linux and MacOS users:
1. Run the script named "unix\_setup.pl" from the repository's root directory by calling "sudo perl unix\_setup.pl". <br>
This automates several steps to ensure Bibliographer functions as expected, including setting up the necessary Save and Raw directories for holding bibliography information, creating a shell alias to the Perl script as "bibliographer", and ensuring that all necessary modules are installed and accessible. <br>
If your shell configuration file is in a nonstandard location, or if you use a shell other than bash, fish, csh, zsh, tsch, or ksh, you may need to add the alias manually in order to facilitate Bibliographer's use in other directories without specifying the full filepath when calling the script. <br>
You may also opt to set up the alias and necessary directories manually if you are uncomfortable using a script to modify the shell configuration file. The manual setup process is described below. Either way I encourage you to review the source code for unix\_setup.pl before running it to check for errors and incompatabilities. <br>
2. Restart your shell for changes to take effect.
3. Run "bibliographer --test" to test the setup. It should print the names of the save and raw directories and a flattering message if setup was successful.

### Linux/MacOS manual configuration:
1. Navigate to the repository's root directory and run "mkdir saved\_bibs && mkdir raw\_bibs" to create the necessary directories.
The script will use these to hold raw bibliography information for use in conversion, and to save bibliographies when a save location is not specified. <br>
2. Find your shell configuration file and add an alias to run main.pl on a new line in the file. 
This will look different depending on the shell used but bash-like shells will usually follow the format "alias bibliographer='perl Path/To/bibliographer/src/main.pl'" or something similar. Consult your shell's documentation to see how aliases are added if you run into any trouble. <br>
This recreates the alias every time the shell is started, making it easier to run the script when you are not in Bibliographer's source directory. <br>
You are welcome to give the alias a different name, but keep the change in mind as it will not be reflected in the --help documentation. <br>
3. There are currently no Perl modules that need to be added manually, but this may change depending on any new features that are added.
4. Restart your shell for changes to take effect.
5. Run "bibliographer --test" to test the setup. It should print the names of the save and raw directories and a flattering message if setup was successful.

### For Windows users:
Sorry but you are SOL right now. I will get around to developing a Windows setup script once the core functionality is complete. <br>
You are welcome to follow the Windows equivalent of the manual setup steps described above to test Bibliographer on your system. <br>

## Using Bibliographer
// To Do:
// bibliographer \[command\] \<args\> \[option\] \<citation style\>
// .rtf only
// must be correctly formatted to parse citation info

## Future directions
When complete, the core functionality of this tool will also include:
- Parsing and export options for OpenOffice/LibreOffice '.odt' and Microsoft Word '.doc' in addition to basic '.rtf'
- Citation completion using an external API(s) to search for missing information, such as authors that were omitted by "et al." rules
- Parsing for incorrectly formatted references, such as those missing punctuation or those which are written in an unconventional format
- A "Fix" command to complete citations that are incorrectly formatted or missing information
- Command-specific behavior for the --help and --test options
- Verbose, quiet, and strict options for modulating the behavior of the script
- Support for APA, Chicago style, Vancouver style, etc.
- Support for reformatting in-text citations as well, so that entire essays can be reformatted without creating a separate bibliography file. (This will include citation ordering ability, as some citation styles are dependent on the sources' order within the text.)
- Complete README with instructions for using the commands, as reflected by the help documentation

