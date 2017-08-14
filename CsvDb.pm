package CsvDb::CsvDb;

use strict;
use warnings;
use DBI;

use CsvDb::Column;

sub new {
	my $class = shift;
	my $self = {
		_conFile => shift,
		_csvFile => shift,
	};
	bless $self, $class;

	my @columns = ();
	my $error = "";

	$self->{_columns} = @columns;
	$self->{_error} = $error;
	return $self;
}

#TODO implement
#"DBI:Pg:dbname=jacob;host=localhost", "postgres", "postgres"
# $myConnection = DBI->connect("DBI:Pg:dbname=jacob;host=localhost", "postgres", "postgres")
	# or die "DB connection error!";
sub con {
	my ($self) = @_;
	my $dbName = "DBI:Pg:dbname=";
	my $host = "host=";
	my $user = "";
	my $pass = "";

	if(! -f $self->{_conFile}) {
		$self->{_error} = "$self->{_conFile} does not exist!\n";
		return 0;
	}

	#TODO read in file
}

#TODO implement
sub readCsv {
	my ($self) = @_;
	print("$self->{_csvFile}\n");
}

sub getConFile {
    my ($self) = @_;
    return $self->{_conFile};
}

sub setConFile {
    my ($self, $conFile) = @_;
    $self->{_conFile} = $conFile if defined($conFile);
}

sub setCsvFile {
    my ($self, $csvFile) = @_;
    $self->{_csvFile} = $csvFile if defined($csvFile);
}

sub getCsvFile {
    my ($self) = @_;
    return $self->{_csvFile};
}

sub getError {
    my ($self) = @_;
    return $self->{_error};
}

1;