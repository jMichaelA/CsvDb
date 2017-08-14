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
    my $dbName = "";
    my $dbHost = "";
    my $dbUser = "";
    my $dbPass = "";

	$self->{_columns} = @columns;
	$self->{_error} = $error;
    $self->{_dbName} = $dbName;
    $self->{_dbHost} = $dbHost;
    $self->{_dbUser} = $dbUser;
    $self->{_dbPass} = $dbPass;

	return $self;
}

# $myConnection = DBI->connect("DBI:Pg:dbname=jacob;host=localhost", "postgres", "postgres")
	# or die "DB connection error!";
sub getCon {
	my ($self) = @_;
	my $dbName = "DBI:Pg:dbname=";
	my $dbHost = "host=";
	my $dbUser = "";
	my $dbPass = "";

	if(! -f $self->{_conFile}) {
		$self->{_error} = "$self->{_conFile} does not exist!\n";
		return 0;
	}

    # read first line of the file
    open my $file, '<', $self->{_conFile};
    my $conDataString = <$file>;
    close $file;

    my @conData = split(',', $conDataString);

    if(scalar(@conData) < 4){
        $self->{_error} = "File not in right format!\nFollow template below:\ndatabase name, host, user, password";
        return 0;   
    }

    # trim off whitespace
    foreach (@conData){
        $_ =~ s/^\s+|\s+$//g;
    }

    $dbName .= $conData[0];
    $dbHost .= $conData[1];
    $dbUser .= $conData[2];
    $dbPass .= $conData[3];

    $self->{_dbName} = $dbName;
    $self->{_dbHost} = $dbHost;
    $self->{_dbUser} = $dbUser;
    $self->{_dbPass} = $dbPass;

}

sub con{
    my ($self) = @_;
    print "$self->{_dbName}\n";
    print "$self->{_dbHost}\n";
    print "$self->{_dbUser}\n";
    print "$self->{_dbPass}\n";
}

#TODO implement
sub readCsv {
	my ($self) = @_;
	print("$self->{_csvFile}\n");
}

# getters and setters
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

sub setDbName {
    my ($self, $dbName) = @_;
    $self->{_dbName} = $dbName if defined($dbName);
}

sub getDbName {
    my ($self) = @_;
    return $self->{_dbname};
}

sub setDbHost {
    my ($self, $dbHost) = @_;
    $self->{_dbHost} = $dbHost if defined($dbHost);
}

sub getDbHost {
    my ($self) = @_;
    return $self->{_dbHost};
}

sub setDbUser {
    my ($self, $dbUser) = @_;
    $self->{_dbUser} = $dbUser if defined($dbUser);
}

sub getDbUser {
    my ($self) = @_;
    return $self->{_dbUser};
}

sub setDbPass {
    my ($self, $dbPass) = @_;
    $self->{_dbPass} = $dbPass if defined($dbPass);
}

sub getDbPass {
    my ($self) = @_;
    return $self->{_dbPass};
}

sub getError {
    my ($self) = @_;
    return $self->{_error};
}

1;