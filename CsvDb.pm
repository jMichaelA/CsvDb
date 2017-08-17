package CsvDb::CsvDb;

use strict;
use warnings;
use DBI;

use CsvDb::Column;

sub new {
	my $class = shift;
    my $conFile = shift;
    my $csvFile = shift;

	my $self = {

	};

	bless $self, $class;

    my $error = "";
    my $dbName = "";
    my $dbHost = "";
    my $dbUser = "";
    my $dbPass = "";

    $self->{_csvFile} = $csvFile if defined $csvFile;
    $self->{_conFile} = $conFile if defined $conFile;
	$self->{_columns} = [];
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
    my $error = 0;

	if(! -f $self->{_conFile}) {
		$self->{_error} = "$self->{_conFile} does not exist!";
		return 0;
	}

    # read first line of the file
    open my $file, '<', $self->{_conFile} or $error = 1;
    
    if($error){
        $self->{_error} = "Could not open $self->{_conFile}";
        return 0;
    }

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

#TODO implement
sub con{
    my ($self) = @_;
    print "$self->{_dbName}\n";
    print "$self->{_dbHost}\n";
    print "$self->{_dbUser}\n";
    print "$self->{_dbPass}\n";
}


sub readCsv {
	my ($self) = @_;
	my $error = 0;
    my $count = 0;
    my $tempCol;
    my @colData = ();
    my @match = ();
    # my @tempData = ();

    open(my $fh, '<:encoding(UTF-8)', $self->{_csvFile}) or $error = 1;
    
    if($error == 1){
        $self->{_error} = "Could not open file $self->{_csvFile}";
        return 0;
    }

    my $firstRow = <$fh>;
    chomp $firstRow;
    chop($firstRow) if ($firstRow =~ m/\r$/);

    # check to make sure there are no commas in the headers
    # future release should handle this
    @match = $firstRow =~ m/"[^",]*,[^,]*"/g;
    if(scalar(@match) > 0){
        $self->{_error} = "Error commas in a header cell is not allowed in $self->{_csvFile}";
        return 0;
    }

    my @columns = split(",",$firstRow);

    for(my $i=0; $i < scalar(@columns); ++$i){
        # remove quotes
        $columns[$i] =~ s/\"//g;
        $tempCol = new CsvDb::Column($columns[$i], $i);
        push @{$self->{_columns}}, $tempCol;
    }

    while (my $row = <$fh>) {
        chomp $row;
        chop($row) if ($row =~ m/\r$/);
        
        # find all strings with commas in them and just change strings to "string"
        # future release should handle this better
        $row =~ s/"[^",]*,[^,]*"/string/g;;
        my @tempData = split(",", $row);
        
        # Separate data into columns
        for(my $i=0; $i < scalar(@tempData); ++$i){
            my @tempArr = ();

            # remove string quotations
            $tempData[$i] =~ s/\"//g;
                        
            if(exists $colData[$i]){
                push @{$colData[$i]}, $tempData[$i];
            }else{
                push @tempArr, $tempData[$i];
                push @colData, \@tempArr;
            }
        }
    }

    for(my $i=0; $i < scalar(@colData); ++$i){
        ${$self->{_columns}}[$i]->setData(\@{$colData[$i]});
        ${$self->{_columns}}[$i]->computeDataType();
    }

    for(@{$self->{_columns}}){
        print $_->getDataType();
        print "\n";
    }
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