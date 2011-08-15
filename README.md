# Overview

This repository contains UNOFFICIAL (custom) brews that have not been accepted
into the master branch.

These brews can be installed via the raw GitHub URLs, or by cloning this
repository locally and installing off the local disk. For more details see
the "using" section below.

# Contents

Brews in this repository are broken out as described below.

* custom:
  These brews provide custom functionality and may duplicate existing OS X
  functionality, though provide newer or bug-fixed versions.

# Using

There are two ways to install packages from this repository.

## Using Raw URLs

First you need to get your hands on the raw URL. For example, the raw url for
a generic formula `example.rb` is:

`https://github.com/AaronKulick/homebrew-alt/raw/master/custom/example.rb`


Pass that URL as a parameter to the `brew install` command, like so:

`brew install https://github.com/AaronKulick/homebrew-alt/raw/master/custom/example.rb`

## Cloning the Repository

Clone the repository to somewhere that you'll remember:

`git clone https://github.com/AaronKulick/homebrew-custom.git /usr/local/LibraryCustom`

This example creates a `LibraryCustom` directory under `/usr/local`.

Then to install a formula pass the full path to the formula into the
`brew install` command. Here's another example that installs example.rb:

`brew install /usr/local/LibraryCustom/custom/example.rb`

# Credit

The alternate homebrew repository concept and the bulk of this text are the original work of Adam Vandenberg (adamv / flangy@gmail.com ) and author of the original homebrew-alt repository:

https://github.com/adamv/homebrew-alt
https://github.com/adamv
