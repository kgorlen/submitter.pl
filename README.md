# submitter.pl -- Email autoresponder to submit photos to the Photochrome Camera Club of SF

See man page for documentation.

## Installation

Install modules locally in `~/bin`, `~/lib`, `~/lib/perl5`, `~/lib/man`:

	perl Makefile.PL INSTALL_BASE=$HOME

Commands to check installed module versions:

	perl -MMIME::Parser -e 'print $MIME::Parser::VERSION ."\n";'
	perl -MMail::Internet -e 'print $Mail::Internet::VERSION ."\n";'
	perl -MImage::Magick -e 'print $Image::Magick::VERSION ."\n";'

submitter.pl test command example:

	perl submitter.pl -submitdir $HOME/submit-test -user submit -debug <./tests/test_widecodepoint.eml
