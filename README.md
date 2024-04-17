# Website Starter Template made from the Official OCaml website

This is a stripped down version of the OCaml website found at https://github.com/ocaml/ocaml.org.

## Features

- **Separation of data editing from HTML/CSS generation:** The data used in the website
  is stored in Yaml or Markdown so users can easily edit it and contribute to the website.
  We generate OCaml code from this data to serve the site content. All the data used in the site can be found in [`./data`](./data).

## Getting started

You can setup the project with:

Before you begin, make sure you have `opam` (OCaml Package Manager) installed on your system. If you haven't installed it yet, you can follow the official installation instructions for your platform:

- [Official `opam` Installation Guide](https://opam.ocaml.org/doc/Install.html)

Once `opam` is installed, you can set up the project and run it with the following commands:

```
make switch
```

And run it with:

```
make start
```

## License

- The source code is released under ISC
- The OCaml logo is released under UNLICENSE.

See our [`LICENSE`](./LICENSE) for the complete licenses.
