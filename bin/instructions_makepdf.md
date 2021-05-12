# Instructions for makepdf

## Introduction

`makepdf` generates a pdf version from a manual. Dependent on the parametrisation on the command line, it builds either a given manual or all. To create a pdf manual, `asciidoctor-pdf` is used as processor. Compared to the build to html which uses a different software from the same family, the parametrisation of `asciidoctor-pdf` can not use the ui-styles, templates and attributes from the html build. Especially for the attribues, this can lead to unresolved "variables" which look quite strange in the build. To overcome this issue, an additional software (`yamlparse`) based on bash is used to dynamically create an attrribute list from `site.yml` which is then added as parameter list to the pdf built. Whenever an attribute change is made in `site.yml`, a new pdf build will use these attribues automatically.

##  Manual Usage

To use `makepdf`, call it from the root of the repo. Dependent on the doc repo you use, the list of buildable manuals may differ.

```
./bin/makepdf -h

Usage: ./bin/makepdf [-c] [-d] [-h] [-m] [-n <admin|user|developer>]

-h ... help
-c ... clean the build/ directory (contains the pdf)
-d ... debug mode, print out with what it would work, only with -m
-m ... build all modules
-n ... build module <name>, only with -m
```

##  Docker Usage

When called from Docker use:

```
"commands": [
  "bin/makepdf -m",
],
```

## How a pdf is Built

The general idea of `asciidoctor-pdf` is, to create a pdf from a given single file and add options to the build command, see the [CLI Options](https://docs.asciidoctor.org/asciidoctor.js/latest/cli/options/) for details. Because the manuals are usually made out of multiple documents, a base document must be created which is then built to pdf. Therefore following method is used: A book template file has to be physically present in the `books/` folder. The following example file shows the basic structure and provides some settings.
```
= ownCloud Desktop Client Manual
The ownCloud Team <docs@owncloud.com>
{revnumber}, {revdate}
:source-highlighter: rouge
:homepage: https://github.com/owncloud/client
:listing-caption: Listing
:toc:
:toclevels: 2
:icons: font
:icon-set: octicon
:module_base_path: modules/ROOT/pages/
```
You can adopt the settings as needed. The `:module_base_path:` is the path to the files of the manual and must be set accordingly.
The script takes this file, adds based on the table of contents of the manual (`nav.adoc`) include statemens like below
```
include::{module_base_path}index.adoc[leveloffset=+1]

include::{module_base_path}installing.adoc[leveloffset=+1]
...
```
and pipes this as source file to the processor.
The output file is saved in the `BUILD_BASE_DIR` or in a subdirectory if there are more than one manuals.

When using the debug mode `-d` of `makepdf` as described above, you will see the base file generated as it would be used when building the pdf.

## Creating a New Documentation Repo

When creating a new documentation repository, you need to to decide if you will have a multi manual documentation or not. Dependent on this decision, you must use a different `makepdf` source file and adopt this to your needs. See the ownCloud Server documentation and the Desktop Client documentation for examples. You can switch everytime your decision by replacing this file. The docker backend process will always use the same call as describe in the docker section.

### For Both Types You Have To

- Provide a book template .adoc file under the `books` directory. Adopt to the requirements.
- Copy the `build`, `fonts` and `resources` directory

### Single Manual

Adopt in `makepdf` following variables according the repo:
```
BOOK_TEMPLATE_NAME="ownCloud_Desktop_Client_Manual"
BUILD_BASE_DIR="build/desktop"
SPEAKING_NAME="Desktop Client"
AVAILABLE_MODULE="ROOT"
```

### Multi Manual

Adopt in `makepdf` following variables according the repo:
```
BUILD_BASE_DIR="build/server"
AVAILABLE_MODULES=(admin user developer)
```
Be aware, that `AVAILABLE_MODULES` is a bash array where the module names are separated by a blank!
Consider that a module name is the name of an array element plus a trailing `_manual` string. This leads to a full name like `admin_manual` which must be a physical present directory located in `modules` directory containing the manual data.  

### Debugging

You will find in `makedf` the creation of the `param` variable. Some of those lines and others are commented. You can uncomment them based on your debugging requirements to print them to the console to see which options are created. this is useful if you test new params or if you run into build errors, see below.

## Build Errors

In very rare cases, it can happen that a pdf build errors. This should not be neglected and resolved. One issue identified (and solved) was a case when using a multi line source bash code block which trailed with a `\`. This  code block would not work in bash, should render properly but did not due to a backend bug, see [pdf creation fails when using a codeblock that ends with \ but has no following line with content](https://github.com/asciidoctor/asciidoctor-pdf/issues/1930). In such cases, use the debug mode, take the file and create a manual build on the command line adding all attributes and comment out all includes. Step by step reenable them and restart the build to see which document is failing. When the problematic file is found, make a copy of the file for backup purposes. Delete all content up to the first section and restart building. Copy back section by section and always do a build. When the problematic section is found do the same thing with the section content. When the issue has been identified, fix it to see if it will build successful. If a scheme is identifyable, fix them all and provide those fixes in the backup file. Finally you can drop the file and rename the backup file to its original name. A normal build should now succeed.
