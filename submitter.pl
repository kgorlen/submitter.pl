#!/usr/bin/perl -w

#
# submitter.pl -- Email autoresponder to submit photos to the Photochrome Camera Club of SF
#
# $Header: /home/photochr/src/perl5/Photochrome/RCS/submitter.pl,v 1.31 2017/12/16 21:57:39 photochr Exp $
#
# Author:
#   Keith Gorlen
#   2335 Jones Street
#   San Francisco CA 94133-2209
#   Email: gorlen@comcast.net
#
#
# $Log: submitter.pl,v $
# Revision 1.31  2017/12/16 21:57:39  photochr
# Implement narrow() to convert code points over 0xFF to text in ack
# email text/plain alternative.
# Prevent dieHandler() from calling reply() if reply() has died.
# Make warnings fatal with stack trace if debugging.
# Print ack email text/plain and text/html alternatives if debugging.
# Correct typos in documentation.
#
# Revision 1.30  2017/04/17 19:48:30  photochr
# Correct link to submission instructions.
#
# Revision 1.29  2016/10/08 01:09:34  photochr
# Set Host to 'localhost' in smtpsend()--causes use of dedicated IP
# when sending email to help avoid having messages blocked as spam.
#
# Revision 1.28  2016/10/07 16:17:12  photochr
# Set "Hello" and "MailFrom" fields in smtpsend() to help avoid
# having messages blocked as spam.
#
# Revision 1.27  2016/04/19 23:26:44  photochr
# Remove unecessary utf8::decode() of recommended_filename.
# Apply encode_utf8() to image file name.
#
# Revision 1.26  2016/04/19 18:06:04  photochr
# Set utf8 mode on STDERR to suppress wide character warnings for
# attachment names.
#
# Revision 1.25  2016/04/17 20:59:20  photochr
# - Apply encode_utf8() to md5_hex() input to avoid "Wide character in subroutine entry" error in hash().
# - Add recommended_name debug output.
#
# Revision 1.24  2014/12/13 02:38:40  photochr
# Overhaul error handling to send error replies.
# Correct handling of UTF-8 attachment filenames.
# Attach "missing image file" thumbnail if no/bad jpeg image submitted.
# Use File::Slurp for jpeg I/O.
# Set Disposition => 'inline' in thumbnail parts (though does not appear to make a difference).
#
# Revision 1.23  2014/10/05 19:06:37  photochr
# Remove $ackEntity->print(\*STDERR) -- duplicates $ackEntity->smtpsend(Debug=>$DebugOpt) output.
#
# Revision 1.22  2014/08/19 18:19:03  photochr
# Move SMTPHOSTS debug.
#
# Revision 1.21  2014/08/18 01:30:06  photochr
# Print SMTPHOSTS for debugging.
#
# Revision 1.20  2014/06/07 21:31:25  photochr
# Make thumbnail from full-size JPEG if embedded thumbnail missing.
#
# Revision 1.19  2013/12/29 01:48:34  photochr
# Remove code to remove UTF enconding tag (unnecessary).
#
# Revision 1.18  2013/06/01 17:11:28  photochr
# Add -replyto to USAGE.
#
# Revision 1.17  2013/02/15 21:44:34  photochr
# Map characters allowed in Mac/Unix filenames but disallowed in Windows to ^.
#
# Revision 1.16  2012/11/18 21:26:57  photochr
# Correct $FILENAME_RE to restrict category to word characters.
#
# Revision 1.15  2012/10/19 18:19:42  photochr
# Remove multiple .jpg/.jpeg extensions from attachement names.
#
# Revision 1.14  2012/10/01 19:52:58  photochr
# Remove -inline option.
# Process inline JPEGs if no JPEG attachments.
# Default width and height in evaluate().
# Update .procmailrc example.
#
# Revision 1.13  2012/09/23 22:14:50  photochr
# Add "submitter:" and submitter email address to die messages so they
# appear in .procmail.log.
# Correct removal of leading/trailing whitespace from attachment name.
# Die if parse errors, no JPEG attachments, or submissions failures to
# enable procmail to save email message in these cases.
#
# Revision 1.12  2012/09/22 22:27:16  photochr
# Change hash range from 0000-9972 to 0001-9973.
# Change all filename and category warnings to fatal errors.
# Add "Submisssion FAILED" message.
# Add "Reply to this message for assistance" message.
# Exit 1 if no attachments.
#
# Revision 1.11  2012/09/09 16:59:35  photochr
# Improve hash() function: include least significant eight hex digits of md5,
# change modulus from 10000 to 9973 (largest prime <10000).
#
# Revision 1.10  2012/09/06 22:14:18  photochr
# Process received Entity as part if no other parts.
# Process sub-parts if X-Mailer = Apple Mail.
# Include link to submission instructions in reply message if errors or warnings.
# Add "Reply to this message for assistance." to reply message.
#
# Revision 1.9  2012/08/20 01:24:32  photochr
# Implement Reply-To header field in acknowledgement email and -replyto command line option.
# Process inline JPEG photos, but keep disabled using new -inline command line option default.
# Only process parts with content-type image/jpeg, image/jpg, or application/octet-stream
# to avoid processing e.g. application/applefile content.
# Set reply To field to $SUPPORT_EMAIL if From undefined, e.g. due to parse failure.
# Set Return-Path header field in acknowledgement email to $SUPPORT_EMAIL for receipt of
# "bounced" email.
# Remove signature from plain/text alternative--not needed with Reply-To.
# Update documentation.
#
# Revision 1.8  2012/08/14 21:20:57  photochr
# Change thumbnailImg() to $thumbnail html template local variable.
# Check email parser results; reply with parser messages if error.
# Generate correct reply header if parse failure.
#
# Revision 1.7  2012/07/22 20:24:04  photochr
# Implement thumbnailImg() for use in acktemplate.html to avoid
# conversion of "cid:" to a link when edited in Thunderbird.
# Use html <code> tag instead of <tt> to denote perl code in
# acktemplate.html.
# Remove leading/trailing whitespace from attachment base name.
# Update documentation.
#
# Revision 1.6  2012/07/21 18:49:02  photochr
# Add -[no]event and -[no]shuffle options.
# Unimplement CCACK environment variable.
# Add hash() to suppress portability warnings.
# Implement additional row-specific local variables in evaluate().
# Remove UTF encoding tag from attachement name.
# Compress whitespace and remove .jpg/.jpeg extension from attachement name.
# Use barewords in hash element references.
# Use attachment name as %Photos key instead of filename.
# Correct category validation logic.
# Add filename to success status messages.
# Complete documentation.
#
# Revision 1.5  2012/07/16 16:17:43  photochr
# Implement -domain and -user options.
# Warn if long edge less than minimum.
# Accept submission of N of M photo sequences.
# Prefix filenames with 4-digit hash to shuffle photos.
# Implement warning messages.
# Support array argument/return values in encode().
# Support optional filename argument in evaluate(); eliminate evalRow().
# Replace decode hex chars and deref operator fix with decode_entities in evaluate().
# Change invalid file name to warning.
# Change invalid category to warning if only one category available for event.
#
# Revision 1.4  2012/06/30 23:10:36  photochr
# Remove whitespace around -'s in filename.
# Fix format of template evaluation debug printout.
# Check for missing future event subdirectory.
# Accept attachments of any type with .jpg filename.
# Overide or default missing category when only one category available.
#
# Revision 1.3  2012/06/20 20:47:50  photochr
# Add text/html part to ack message.
# Simplify text/plain ack message.
#
# Revision 1.2  2012/06/14 20:22:12  photochr
# Implement -ccack option.
# Change debug separator from --- to ***.
# Add summary line to ack email.
#
# Revision 1.1  2012/06/13 05:09:27  photochr
# Initial revision
#
#

use FindBin;
use File::Slurp;
use Digest::MD5 qw(md5_hex);
use MIME::Parser;
use HTML::Entities;
use Encode qw(decode decode_utf8 encode_utf8);
use Getopt::Long;
use Time::localtime;
use Image::ExifTool;
use Image::Magick;
use Carp qw{cluck};

$VERSION = sprintf "%d.%03d", q$Revision: 1.31 $ =~ /(\d+)\.(\d+)/g;

use strict;
use warnings;

#
# Global constants
#

my $USAGE = "USAGE: submitter.pl [ -domain <name> ] [ -user <name> ] [ -submitdir <directory> ]
                [ -event <yyyy-mm-dd> ] [ -ccack <address> ] [ -replyto <address> ]
                [ -[no]store ] [ -[no]acknowledge ] [ -[no]shuffle ] [ -[no]debug ] [ email ]\n";

my $REV = substr(q$Revision: 1.31 $, 10);

my $MAXLONGEDGE = 1024;		# Maximum long edge of photo in pixels
my $MINLONGEDGE = 1000;		# Minimum long edge of photo in pixels
my $FILENAME_RE = qr/^\s*(\w+)\s*-\s*([^-]+?)\s*-\s*(.+?)\s*(-\s*[1-9]\s*of\s*[1-9])?$/i; # Valid attached file name RE
my $SUPPORT_EMAIL = 'support@photochrome.org';
my $INSTRUCTIONS = 'http://photochrome.org/members-info/submission-instructions'; # Link to submission instructions
my $MISSINGFILE = $FindBin::Bin.'/missing-image.jpg';	   # Missing file icon

#
# Initialize global variables
#

my $SubmitDir = "$ENV{HOME}/submissions"; # Top-level directory to store submitted photos
my $UserOpt =  'submit';	# Autoresponder email account name
my $DomainOpt = 'photochrome.org';	# Domain name
my $EventDateOpt;		# Override next event date
my @CcAcksOpt = ();		# Email addresses for acknowledgement Cc:
my @ReplyToOpt = ($SUPPORT_EMAIL);# Email addresses for Reply-To
my $StoreOpt = 1;		# Store photos in directory
my $AckOpt = 1;			# Send acknowledgement email
my $ShuffleOpt = 1;		# Prefix filenames with hash to shuffle when sorted
my $DebugOpt = 0;		# Enable debugging
my $Replying = 0;		# Set while executing reply() to disable call from dieHandler()
my $Inline = 0;			# Process inline photos
my $EventMMDDYYYY = '?';	# Event date MM/DD/YYYY
my $SubmitterEmail = '?';	# Submitter email address
my $AckEntity;			# MIME::Entity for acknowledgement email
my $AttachCount = 0;		# Count of files attached
my $SubmitCount = 0;		# Count of photos successfully submitted
my $ResubmitCount = 0;		# Count of photos successfully resubmitted
my $WarnCount = 0;		# Count of warnings
my $FailedCount = 0;		# Count of photos failed submissions
my @Categories;			# Categories available for event
my %Photos;			# $Photos{attachment-name} = \(
				#	JPEG => jpeg ref
				#	Category => category to which submitted
				# 	ThumbnailCid => unique content ID
				#	Status => [error/warning descriptions]
				# 	ImageWidth => pixels
				# 	ImageHeight => pixels
				# 	ImageSize => WxH
				# 	ThambnailImage => jpeg thumbnail
				# )

umask 0077;			# Default access only to file/directory owner
binmode(STDERR, ":utf8");       # Attachment names may be UTF-8
STDERR->autoflush(1);

#
# cid -- Generate unique content ID
#

sub cid {
    return substr(md5_hex(time().$AttachCount),0,24)."-$DomainOpt";
}

#
# hash -- Generate 4-digit hash prefix for shuffling photos
#

sub hash {
    no warnings; # suppress "Hexadecimal number > 0xffffffff non-portable" warning from hex()
    my $md5 = md5_hex(map encode_utf8($_), @_);
    return sprintf '%04u', (hex(substr($md5,0,16)) ^ hex(substr($md5,16,16))) % 9973 + 1;
}

#
# Convert Unicode to text
#

sub narrow {
    my @str = @_;

    foreach my $s (@str) {
	$s = join("",
	     map { $_ > 255                    # if wide character...
		       ? sprintf("\\x{%04X}", $_)  # \x{...}
		       : chr($_) =~ /[[:cntrl:]]/  # else if control character...
		       ? sprintf("\\x%02X", $_)  # \x..
		       : chr($_)		# else as themselves
	     } unpack("W*", $s));           # unpack Unicode characters
    }

    return wantarray ? @str : $str[0];
} 

#
# encode -- encode unsafe html characters
#

sub encode {
    my @safe = map(encode_entities($_), @_);
    return wantarray ? @safe : $safe[0];
}

#
# evaluate -- evaluate <code>expr</code> expressions in html template
#

sub evaluate {
    my $template = shift;	# html template
    my $n = shift || '';	# Optional photo name

    my ($category, $artist, $title, $sequence, $width, $height, $size, $thumbnail, @status);

    if ($n) {
	($category, $artist, $title, $sequence) = ($n =~ $FILENAME_RE);	
	$category = $Photos{$n}->{Category} || '?';
	$artist ||= '?';
	$sequence ||= '';
	$title ||= '?';
	$title .= $sequence;
	$width = $Photos{$n}->{ImageWidth} || '?';
	$height = $Photos{$n}->{ImageHeight} || '?';
	$size = length(${$Photos{$n}->{JPEG}});
	$thumbnail = qq(<img src="cid:$Photos{$n}->{ThumbnailCid}">);
	@status = @{$Photos{$n}->{Status}};
    }

    if ($DebugOpt) {
	$_ = $template;
	while (s/<code>(.+?)<\/code>/$1/s) {
	    print STDERR decode_entities($1), ": ", eval decode_entities($1), "\n";
	}
	print STDERR "\n***\n";
    }

    $template =~ s/<code>(.+?)<\/code>/decode_entities($1)/eesg;
    return $template;
}

#
# Send reply email
#

sub reply {
    $Replying = 1;

    if ($DebugOpt) {
	$AckEntity->print(\*STDERR) unless $AckOpt;
	print STDERR ">>> SMTPHOSTS=", $ENV{SMTPHOSTS} || '';
	print STDERR "\n***\n";
    }

    $AckEntity->smtpsend(
	Debug=>$DebugOpt,
	Host=>'localhost',
	Hello=>$ENV{SMTPHOSTS},
	MailFrom=>"$UserOpt\@$DomainOpt"
	) or die "smtpsend FAILED: $!, stopped" if $AckOpt;

    $Replying = 0;
}

#
# Handle die exceptions
#

sub dieHandler {
    my ($msg) = @_;	# die message text

    die "submitter $SubmitterEmail: ", @_
	if !$AckEntity || $Replying; # Reply to email not possible

    $msg =~ s/^\s*(.*?)\s*(, stopped at .* line \d+\.)?$/$1/i;

# Plain text part

    $AckEntity->attach(Type => 'text/plain; charset=utf-8',
		       Encoding => '7bit',
		       Data => $msg . "\nReply to this message for assistance.\n");

# HTML part

    my $ackHTML = <<HTML;
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
    </head>
    <body>
HTML

    $ackHTML .= "<b>$msg</b><br><br>Reply to this message for assistance.<br>";

    $ackHTML .= <<HTML;
    </body>
</html>
HTML

    $AckEntity->attach(Type => 'text/html; charset=utf-8',
		      Encoding => '7bit',
		      Data => $ackHTML);
    reply;

    die "submitter $SubmitterEmail: ", @_;
}

$SIG{__DIE__} = \&dieHandler;

# Get options

GetOptions("submitdir=s",	\$SubmitDir,
	   "user=s",		\$UserOpt,
	   "domain=s",		\$DomainOpt,
	   "event=s",		\$EventDateOpt,
	   "ccack=s",		\@CcAcksOpt,
	   "replyto=s",		\@ReplyToOpt,
	   "acknowledge!",	\$AckOpt,
	   "shuffle!",		\$ShuffleOpt,
	   "store!",		\$StoreOpt,
	   "debug!",		\$DebugOpt,
	   )
    or die "submitter: $USAGE";

# Make warnings fatal with stack trace if debugging

$SIG{__WARN__} = sub {
    cluck "warn handler: ", @_;
} if $DebugOpt;

# Create parser and set parsing options:

my $parser = new MIME::Parser;
$parser->output_to_core(1);

# Parse received message

my $RcvdEntity = $parser->parse(\*STDIN) or die "submitter: email message parse FAILED, stopped";
my $ParseResults = $parser->results;

if ($DebugOpt) {
    if ($ParseResults->msgs) {
	print STDERR join("\n", $ParseResults->msgs), "\n--\n";
    }

    $RcvdEntity->dump_skeleton(\*STDERR);
    print STDERR "\n***\n";
}

$SubmitterEmail = $RcvdEntity->head->get('From') || '?';
$SubmitterEmail =~ s/^[\s\n]*(.*?)[\s\n]*$/$1/; # remove leading/trailing whitespace/newlines

# Build acknowledge message header

my @header = (Type => 'multipart/alternative',
	      From => "$UserOpt\@$DomainOpt",
	      To => $RcvdEntity->head->get('From') || join(',', @ReplyToOpt),
	      Subject => "Re: " . ($RcvdEntity->head->get('Subject') || "[Photochrome submission]"),
	      'Reply-To' => join(',', @ReplyToOpt),
	      'Return-Path' => $SUPPORT_EMAIL,
	      'X-Loop' => "$UserOpt\@$DomainOpt",
	      );

if ($_ = $RcvdEntity->head->get('Message-ID')) {
    push @header, 'References', $_;
    push @header, 'In-Reply-To:', $_;
}

push(@header, 'CC', join(',', @CcAcksOpt)) if @CcAcksOpt;

$AckEntity = new MIME::Entity->build(@header);

# Process parser errors

if ($ParseResults->errors) {
    my $ackText = "Photo submission FAILED!\n\n";
    $ackText .= "Error details:\n" . join("\n", $ParseResults->msgs) . "\n";
    $ackText .= "Reply to this message for assistance.\n";

    $AckEntity->attach(Type => 'text/plain; charset=utf-8',
		       Encoding => '7bit',
		       Data => $ackText);

    my $ackHTML = <<HTML;
<html>
    <head>
      <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
    </head>
    <body><b>Photo submission FAILED!</b><br>
    <br>
    Error details:<br>
HTML
  
    $ackHTML .= '<pre>' . join("\n",encode($ParseResults->msgs)) . "\n" . '</pre>';
    $ackHTML .= "<br>Reply to this message for assistance.<br>";

    $ackHTML .= <<HTML;
    </body>
</html>
HTML

    $AckEntity->attach(Type => 'text/html; charset=utf-8',
		      Encoding => '7bit',
		      Data => $ackHTML);
    reply;		# Send email parse error details

    print STDERR "submitter $SubmitterEmail: Email parse errors\n";
    exit 1;
}

# Check for missing image data icon file

my $MissingThumb;		# Missing image data icon
die "$MISSINGFILE missing or unreadable, stopped"
    unless -r $MISSINGFILE;

# Find directory for next event date

opendir(my $dh, $SubmitDir)
    or die "opendir($SubmitDir) FAILED: $!, stopped";
chdir $SubmitDir or die "chdir($SubmitDir) FAILED: $!, stopped";

my $now = localtime;
my $nowYYYYMMDD = sprintf "%04d-%02d-%02d", $now->year()+1900, $now->mon+1, $now->mday;
my ($eventYYYYMMDD) = $EventDateOpt ||
    sort map( ($nowYYYYMMDD lt $_ ? ($_) : ()),
	      grep { /^\d\d\d\d-\d\d-\d\d$/ && -d $_ } readdir($dh));
closedir $dh;

die "No future events scheduled [$SubmitDir], stopped" unless $eventYYYYMMDD;

$eventYYYYMMDD =~ /^(\d\d\d\d)-(\d\d)-(\d\d)$/;
$EventMMDDYYYY = "$2/$3/$1";

# Read names of category subdirectories

opendir($dh, $eventYYYYMMDD)
    or die "opendir($SubmitDir/$eventYYYYMMDD) FAILED: $!, stopped";
chdir "$SubmitDir/$eventYYYYMMDD" or die "chdir($SubmitDir/$eventYYYYMMDD) FAILED: $!, stopped";

@Categories = grep { !/^\./ && -d $_ } readdir($dh);
closedir $dh;

die "No category subdirectories in $SubmitDir/$eventYYYYMMDD, stopped"
    unless @Categories;

print STDERR "Categories in $SubmitDir/$eventYYYYMMDD: ", join(' ', sort @Categories), "\n***\n"
    if $DebugOpt;

# Set options for reading EXIF

my $exifTool = new Image::ExifTool;
$exifTool->Options(Duplicates => 0);


#
# Process jpeg image attachments
#

sub processParts {
    my $n;			# current attachment name
    my $errors;			# number of errors for current attachment

    foreach my $part (@_) {
	$errors = 0;

	$n = $part->head->recommended_filename || '';
	print STDERR ">>> recommended_filename: $n", utf8::is_utf8($n) ? " (UTF-8)\n":"\n"
	    if $DebugOpt;

	if ($n =~ /=\?.+\?\w+\?.*\?=/) {
	    $n = Encode::decode('MIME-Header', $n);
	}

	print STDERR ">>> Attachment name: $n", utf8::is_utf8($n) ? " (UTF-8)\n":"\n"
	    if $DebugOpt;

	unless ($n =~ /\.jpe?g$/i &&
		$part->head->mime_type =~ /^image\/jpe?g$|^application\/octet-stream$/i
		) {
	    processParts($part->parts) if $Inline;	# process sub-parts for inline photos
	    next;
	}

	$n =~ s/^\s*(.*?)(\s*\.jpe?g)+$/$1/i;  # remove extension(s) and leading/trailing whitespace
	$n =~ s/\s+/ /g;	# compress whitespace in attachment name

	$Photos{$n} = {
	    JPEG => \q(),
	    Category => '',
	    ThumbnailCid => cid,# unique content ID for thumbnail attachments
	    Status => [],
	};

	$AttachCount++;

# Validate filename and category

	my ($category, $artist, $title, $sequence) = ($n =~ $FILENAME_RE);	
	$category ||= '';
	$artist ||= '';
	$title ||= '';
	$sequence ||= '';

	if ($category) {	# valid attachment filename
	    ($category) = grep(/^$category$/i, @Categories); # So category case matches subdirectory
	    unless ($category) {
		push @{$Photos{$n}->{Status}},
		    "ERROR: Invalid category (available categories: @{[join(',', @Categories)]})";
		$errors++;
	    }
	} else {
	    push @{$Photos{$n}->{Status}},
	    	"ERROR: Invalid attachment name (must be: <Category>-<First Name> <Last Name>-<Title>.jpg)";
	    $errors++;
	}

	$Photos{$n}->{Category} = $category || '';

# Extract JPEG data

	my $jpegref = \$part->bodyhandle->as_string; # Reference to JPEG image
	unless ($jpegref) {
	    push @{$Photos{$n}->{Status}},
		"ERROR: JPEG image data missing";
	    $errors++;
	    next;
	}
	$Photos{$n}->{JPEG} = $jpegref;

# Read EXIF

	my $exif = $exifTool->ImageInfo($jpegref,
					'ImageSize',
					'ImageWidth', 'ImageHeight',
					'ThumbnailImage');
	unless ($exif) {
	    push @{$Photos{$n}->{Status}},
		"ERROR: EXIF data missing";
	    $errors++;
	    next;
	}

	for (keys %$exif) { $Photos{$n}->{$_} = $exif->{$_} };

	unless ($Photos{$n}->{ThumbnailImage}) {
	    if ($Photos{$n}->{ImageSize}) { # Make thumbnail from full-size JPEG
		print STDERR "No thumbnail; creating from resized JPEG\n" if $DebugOpt;
		my $tn = Image::Magick->new(magick=>'jpg');
		$tn->BlobToImage($$jpegref);
		$tn->Resize(geometry=>'100x100');
		$Photos{$n}->{ThumbnailImage} = \scalar($tn->ImageToBlob());
	    } else {		# Use missing image icon
		$MissingThumb = read_file($MISSINGFILE,  binmode => ':raw', scalar_ref => 1)
		    unless $MissingThumb;
		die "read_file($MISSINGFILE) FAILED, stopped"
		    unless $MissingThumb;;

		$Photos{$n}->{ThumbnailImage} = $MissingThumb;
	    }
	}

	if ($DebugOpt) {
	    print STDERR "ImageSize:      ", $Photos{$n}->{ImageSize} || '?', "\n";
	    print STDERR "ImageWidth:     ", $Photos{$n}->{ImageWidth} || '?', "\n";
	    print STDERR "ImageHeight:    ", $Photos{$n}->{ImageHeight} || '?', "\n";
	    print STDERR "ThumbnailImage: ", length(${$Photos{$n}->{ThumbnailImage}}), " bytes\n";
	    print STDERR "***\n";
	}

# Check photo dimensions

	my $width = $Photos{$n}->{ImageWidth} || 0;
	my $height = $Photos{$n}->{ImageHeight} || 0;

	if ($width == 0 || $height == 0) {
	    push @{$Photos{$n}->{Status}},
		"ERROR: Image data missing";
	    $errors++;
	    next;
	}

	if ($width > $MAXLONGEDGE || $height > $MAXLONGEDGE) {
	    push @{$Photos{$n}->{Status}},
		"ERROR: Long dimension of ${width}x$height photo exceeds $MAXLONGEDGE";
	    $errors++;
	    next;
	}

	if ($width < $MINLONGEDGE && $height < $MINLONGEDGE) {
	    push @{$Photos{$n}->{Status}},
		"WARNING: Long dimension of ${width}x$height photo less than $MINLONGEDGE";
	    $WarnCount++;
	}

	next if $errors;
	next unless $StoreOpt;

# Calculate shuffle hash and assemble file name

	my $hash = $ShuffleOpt ? hash($eventYYYYMMDD,$category,$artist,$title || $n).'-' : '';
	my $fn = "$hash$category-$artist-$title$sequence.jpg";
	$fn =~ tr(|\?*<":>/)/^/;   # map characters disallowed in Windows to ^

	print STDERR ">>> JPEG filename: $fn", utf8::is_utf8($fn) ? " (UTF-8)\n":"\n"
	    if $DebugOpt;

# Write image file

	my $encodedfn = encode_utf8("$category/$fn");
	my $replace = -s $encodedfn;	# replace if file exists

	unless (write_file($encodedfn,
			   { binmode => ':raw', err_mode => 'quiet' },
			   $Photos{$n}->{JPEG})) {
	    push @{$Photos{$n}->{Status}}, "write_file FAILED: $!";
	    $errors++;
	    next;
	};

	unless ($replace) {
	    push @{$Photos{$n}->{Status}}, "Successfully submitted, file: $fn";
	    $SubmitCount++;
	} else {
	    push @{$Photos{$n}->{Status}}, "Successfully resubmitted, file: $fn";
	    $ResubmitCount++;
	}

    } continue {
	if ($errors) {
	    push @{$Photos{$n}->{Status}}, "Submission FAILED, please correct errors and resubmit";
	    $FailedCount++;
	}
    }
}

while (!$AttachCount && $Inline < 2) {
    if ($RcvdEntity->parts) {
	processParts($RcvdEntity->parts);
    } else {
	processParts($RcvdEntity);
    }

    $Inline++;		# No JPEG attachments--look for inline photos
}

die "No JPEG attachments\n" unless $AttachCount;

#
# Build acknowledgement email message
#

#
# Build plain text alternative
#

my $ackText =
    "$AttachCount photo(s) attached; $SubmitCount submitted, $ResubmitCount resubmitted, $FailedCount failed, $WarnCount warning(s)\n";
$ackText .= "Please see $INSTRUCTIONS for instructions.\n" if $FailedCount || $WarnCount;
$ackText .= "Categories available for $EventMMDDYYYY: @{[join(' ', @Categories)]}\n\n";

foreach my $n (sort keys %Photos) {
	foreach my $status (@{$Photos{$n}->{Status}}) {
	    $ackText .= "$n: $status";
	    if ($status =~ /^Success/i) {
		$ackText .= " (" . ($Photos{$n}->{ImageWidth} || '?')
		    . 'w x ' . ($Photos{$n}->{ImageHeight} || '?') . 'h pixels, '
		    . length(${$Photos{$n}->{JPEG}}) . " bytes)";
	    }
	    $ackText .= "\n";
	}
	$ackText .= "\n";
    }
$ackText = narrow($ackText);

if ($DebugOpt) {
    print STDERR ">>> Ack email text/plain alternative:\n", $ackText;
    print STDERR "\n***\n";
}

$AckEntity->attach(Type => 'text/plain; charset=utf-8',
		   Encoding => '7bit',
		   Data => $ackText);

#
# Build html alternative
#

my $ackParts = $AckEntity->attach(Type => 'multipart/related',
				  Encoding => '7bit',
				  );

my $ackHTML;

if (keys %Photos) {

# Read html template for ack message

    my $ackTemplate;

    my $fh;
    open($fh, "<", "$SubmitDir/acktemplate.html")
	or die "open $SubmitDir/acktemplate.html FAILED: $!, stopped";
    {
	local $/;
	$ackTemplate = <$fh>;
    }
    close $fh;

    my ($preamble, $tableRow, $postamble) = $ackTemplate =~ /^(.+)(<tr>.+<\/tr>)(.+)$/si;

    $ackHTML = evaluate($preamble);

    foreach my $n (sort keys %Photos) {
	$ackHTML .= evaluate($tableRow, $n);
    }

    $ackHTML .= evaluate($postamble);

}

if ($DebugOpt) {
    print STDERR ">>> Ack email text/html alternative:\n", $ackHTML;
    print STDERR "\n***\n";
}

$ackParts->attach(Type => 'text/html; charset=utf-8',
		   Encoding => '7bit',
		   Data => $ackHTML);

# Build thumbnail image parts

foreach my $n (sort keys %Photos) {
    my $tn = $Photos{$n}->{ThumbnailImage};

    $ackParts->attach(Type => 'image/jpeg',
		      Encoding => 'base64',
		      Disposition => 'inline',
		      Id => "<$Photos{$n}->{ThumbnailCid}>",
		      Data => $$tn);
}

reply;			# Send acknowledgement email

if ($FailedCount) {
    print STDERR "submitter $SubmitterEmail: $FailedCount submission(s) failed\n";
    exit 1;
}

1;
__END__

=head1 NAME

submitter.pl -- Store and acknowledge JPEG photos submitted for Photochrome Camera Club events

=head1 SYNOPSIS

B<submitter.pl> [B<-domain> I<name>] [B<-user> I<name>] [B<-submitdir>
I<directory>] [B<-event> I<yyyy-mm-dd>] [B<-ccack> I<address>] [B<-replyto> I<address>]
[B<-[no]store>] [B<-[no]acknowledge>] [B<-[no]shuffle>] [B<-[no]debug>] I<email-message>

=head1 DESCRIPTION

This script is run from procmail to store JPEG photos in a submissions
directory and return an acknowledgement email message to the sender.

JPEG image attachments are expected to have filenames of the form:

=over 4

I<Category>C<->I<Artist>C<->I<Title>C<.jpg> (or C<.jpeg>)

or

I<Category>C<->I<Artist>C<->I<Title>C<->I<N>C< of >I<M>C<.jpg> (or C<.jpeg>)

=back

where:

=over 4

=item I<Category>

is the case-insensitive name of a submissions subdirectory (C<OS>, C<Pic2>, C<TN>, etc.)

=item I<Artist>

is the first and last name of the photographer

=item I<Title>

is the photo's title

=item I<N>C< of >I<M>

indicates that this is the I<N>th photo in a sequence of I<M> photos
that should be shown together.  I<N> and I<M> must be in the range
1-9.

=back

Submitted photos must have a maximum long side dimension of 1024
pixels.

The script stores the jpegs in directories with names like
C<~/submissions/>I<YYYY-MM-DD>C</>I<Category>, where I<YYYY-MM-DD> is
the event date and I<Category> is the code for the category on that
date.  The script accepts submissions only for the categories created
for the next meeting date.  On the day of a meeting, it switches to
accepting submissions for the next meeting, so the photos for the
current meeting are frozen and can be copied to a laptop for
projection later that day.  The script replies with an email message
reporting the status of the submitted photos.

=head2 Example .procmailrc

  PATH=/usr/bin:/usr/local/bin
  MAILDIR=/var/spool/mail/photochrome.org
  LOGFILE=$HOME/.procmail.log
  VERBOSE=yes
  COMSAT=no
  PERL5LIB=$HOME/perl/lib

  :0
  * ^(To|Cc|X-Forwarded-To):.*projectionist@photochrome.org
  {
	  :0
	  * !^FROM_DAEMON
	  * !^X-Loop: submit@photochrome.org
	  {
		  :0 wc
		  | $HOME/perl/bin/submitter.pl -user projectionist

# Deliver to failures mailbox if submission failure
		  :0 e
		  failures/
	  }

	  :0
	  /dev/null
  }

=head1 OPTIONS

=over 4

=item B<-domain> I<name>

Set the domain of the reply email message header to I<name> (default:
C<photochrome.org>).

=item B<-user> I<name>

Set the user of the reply email message header to I<name> (default:
C<submit>).

=item B<-submitdir> I<directory>

Set the top-level directory for submitted files to I<directory>
(default: C<$HOME/submissions>).

=item B<-event> I<yyyy-mm-dd>

Set the submission event date to I<yyyy-mm-dd> (default: next event
date after today).

=item B<-ccack> I<address>

Send a copy of reply messages to I<address>.

=item B<-replyto> I<address>

Additional Reply-To email I<address>.

=item B<-[no]store>

Write JPEG photos to target category directory (default: true).

=item B<-[no]acknowledge>

Send acknowledgement email reply message (default: true).

=item B<-[no]shuffle>

Prefix filename with 4-digit hash to shuffle photos (default: true).

=item B<-[no]debug>

Print debug output to STDERR (default: false).

=back

=head1 FILES

=head2 C<acktemplate.html>

The format of the html acknowledgement email reply message is defined by the
C<acktemplate.html> file in the submission directory.  The template consists
of an html table with a single row plus surrounding text.  The table row is
interpreted once for each JPEG attachment.

Text in the template tagged as C<E<lt>codeE<gt>> ... C<E<lt>/codeE<gt>> is
interpreted as a perl expression, which is evaluated and replaced by
the result.

Thunderbird can be used to edit C<acktemplate.html>: write a message, click
in the message area, select Insert->HTML..., copy and paste the current
contents of C<acktemplate.html> into the pop-up window, select "Insert",
edit the template, then select Save->File... to save the new template.

=head3 Utility Subroutines

=over 4

=item C<encode>(I<string1>, I<string2>, ...)

Calls HTML::Entities to replace unsafe characters in the argument
strings with their HTML entity representations.  Returns an array of
encoded strings in array context, or the first encoded string in
scalar context.

=back

=head3 Global Constants and Variables

The following variables may be referenced anywhere in an html
template:

=over 4

=item C<$EventMMDDYYYY>

The event date in MM/DD/YYYY format.

=item C<$AttachCount>

The number of JPEG file attachments.

=item C<$SubmitCount>

The number of JPEG photos successfully submitted.

=item C<$ResubmitCount>

The number of JPEG photos successfully resubmitted; i.e., a previously
submitted photo with the same name was overwritten.

=item C<$WarnCount>

The number of warnings issued.

=item C<$FailedCount>

The number of unsuccessful JPEG photo submissions.

=item C<$INSTRUCTIONS>

A link to photo submission instructions.

=item C<@Categories>

An array containing the names of the categories available for the
current event.

=item C<%Photos>

A hash, keyed by attachment name, containing the following fields for
each attachment:

=over 4

=item C<JPEG>

A reference to the JPEG image data.

=item C<Category>

The (valid) category to which the photo is submitted.

=item C<ThumbnailCid>

The unique content id of the associated thumbnail image of the photo.

=item C<Status>

A reference to an array of strings of warning, error, and
informational messages for the submitted photo.

=item C<ImageWidth>

The width of the photo in pixels, or C<'?'> if unknown.

=item C<ImageHeight>

The height of the photo in pixels, or C<'?'> if unknown.

=item C<ThumbnailImage>

The reference to the JPEG thumbnail image data.

=back

=back

=head3 Table Row Variables

The following variables may be referenced only within the table row
portion of an html template:

=over 4

=item C<$n>

The name of the attachment with the .jpg or .jpeg extension removed,
leading/trailing whitespace removed, and multiple whitespace character
sequences replaced by a single space.

=item C<$category>

The (valid) category to which the photo is submitted, or C<'?'> if
none.

=item C<$artist>

The photographer's first and last name, or C<'?'> if the attachment
name is invalid.

=item C<$title>

The photo's title, or C<'?'> if the attachment name is invalid.

=item C<$sequence>

The photo's I<N> C<of> I<M> sequence number, or empty if none.

=item C<$width>

The width of the photo in pixels, or C<'?'> if unknown.

=item C<$height>

The height of the photo in pixels, or C<'?'> if unknown.

=item C<$size>

The size of the JPEG image data in bytes.

=item C<thumbnail>

An html C<img> tag to insert the thumbnail image extracted from the JPEG image.

=item C<@status>

An array of strings of warning, error, and informational messages for
the submitted photo.

=back

=head1 REQUIRES

Digest::MD5 qw(md5_hex), MIME::Parser, HTML::Entities, Getopt::Long,
Time::localtime, Image::ExifTool

=head1 SEE ALSO

procmail, .procmailrc

C<http://photochrome.org/club-info/submissions>

=head1 AUTHOR

  Keith Gorlen
  gorlen@comcast.net

=cut
