## Configuration

Create a `config.hash` from the example:

    cp config.hash.example config.hash
    vi config.hash

And update the username, password, and vendor number for your
iTunes Connect acount. This file is expected to be Ruby code, the last
statement resulting in a Ruby Hash object.

## Usage

To fetch all available reports, run:

    ./fetch

