package CsvDb::CsvDb;

use strict;
use warnings;
use DBI;

use CsvDb::Column;

sub new {
    my $class = shift;
    my $conFile = shift;
    my $csvFile = shift;

    my $self = {};

    bless $self, $class;

    my $error = "";
    my $dbName = "";
    my $dbHost = "";
    my $dbUser = "";
    my $dbPass = "";
    my $tableName = "";

    $self->{_csvFile} = $csvFile if defined $csvFile;
    $self->{_conFile} = $conFile if defined $conFile;
    $self->{_columns} = [];
    $self->{_error} = $error;
    $self->{_dbName} = $dbName;
    $self->{_dbHost} = $dbHost;
    $self->{_dbUser} = $dbUser;
    $self->{_dbPass} = $dbPass;
    $self->{_table} = $tableName;
    $self->{_id} = "id";

	return $self;
}

# $myConnection = DBI->connect("DBI:Pg:dbname=jacob;host=localhost", "postgres", "postgres")
	# or die "DB connection error!";
sub getCon {
    my ($self) = @_;
    my $dbName = "DBI:Pg:dbname=";
    my $dbHost = ";host=";
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

sub runQuery{
    my ($self, $query) = @_;
    my $error = 0;

    my $myConnection = DBI->connect("$self->{_dbName} $self->{_dbHost}", "$self->{_dbUser}", "$self->{_dbPass}")
        or $error = 1;

    if($error){
        $self->{_error} = "Could not connect to db check credentials";
        return 0;
    }

    $query = $myConnection->prepare($query)
        or $error = 1;

    my $result = $query->execute()
        or $error = 1;

    if($error){
        $self->{_error} = "Query failed";
        return 0;
    }
    return $query
}


sub readCsv {
    my ($self) = @_;
    my $error = 0;
    my $count = 0;
    my $tempCol;
    my @colData = ();
    my @match = ();

    # future needs to be able to detect dos line endings and convert to unix
    # for now it's assuming it's dos
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
}

sub createTable{
    my ($self) = @_;
    if(!$self->{_tableName}) {
        $self->{_error} = "Error tablename needs to be set";
        return 0;
    }
    my $transaction = "BEGIN;\n";
    $transaction .= "CREATE TABLE $self->{_tableName} (\n";
    $transaction .= "$self->{_id} serial primary key";
    
    my $name;
    my $dataType;
    foreach(@{$self->{_columns}}){
        $name = $_->getName();
        $dataType = $_->getDataType();
        $transaction .= ",\n$name $dataType";
    }

    # $transaction .= "\n);\nROLLBACK;";
    $transaction .= "\n);\nCOMMIT;";
    $self->runQuery($transaction);
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

sub setTableName {
    my ($self, $table) = @_;
    $self->{_tableName} = $table if defined($table);
}

sub getTableName {
    my ($self) = @_;
    return $self->{_tableName};
}

sub setId {
    my ($self, $id) = @_;
    $self->{_id} = $id if defined($id);
}

sub getId {
    my ($self) = @_;
    return $self->{_id};
}
1;