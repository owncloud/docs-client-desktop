# Client - Desktop Documentation

## Building the Docs

The desktop client documentation is not built independently. Instead, it is built together with the [core documentation](https://github.com/owncloud/docs/). However, you can build a local copy of the desktop client documentation to preview changes you are making.

## Prepare Your Environment

To prepare your local environment, clone this repository and run
```
yarn install
```
to setup all necessary dependencies.

**Note**, these commands require NodeJS and Yarn to be installed. To learn more about how to install them, refer to the [documentation in the docs repository](https://github.com/owncloud/docs/blob/master/docs/getting-started.md).

## Building the Client Documentation

Run the following command to build the client documentation

```
yarn antora-local
```

## Previewing the Generated Docs

Assuming that there are no build errors, the next thing to do is to view the result in your browser. In case you have already installed a web server, you need to configure a virtual host (or similar) which points to the directory `public/`, located in the `docs/` directory of this repository. This directory contains the generated documentation. Alternatively, use the simple server bundled with the current package.json, just execute the following command to serve the documentation at [http://localhost:8080/desktop/](http://localhost:8080/desktop/):

```
yarn serve
```
