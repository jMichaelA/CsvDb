package CsvDb::Column;

use strict;
use warnings;

sub new {
	my $class = shift;
	my $self = {
		_name => shift,
		_colNum => shift
	};
	bless $self, $class;

	my $dataType = "";
	my @data = ();
	my $error = "";

	$self->{_dataType} = $dataType;
	$self->{_data} = @data;
	$self->{_error} = $error;

	return $self;
}

sub computeDataType {
	my $self = shift;
	my $data = shift;

	$self->{_data} = $data if defined $data;

	if(scalar($self->{_data}) == 0){
		$self->{_error} = "Data not defined. Please provide some example data.";
		return 0;
	}
	
	my $temp;

	for(@{$self->{_data}}){
		if($_ eq ""){
			next;
		}

		#check numeric
		if($_  =~ m/^-?(0|([1-9][0-9]*))(\.[0-9]+)?([eE][-+]?[0-9]+)?$/){
			$temp = $_;

			#remove floating point
			$temp = substr($temp, 0, index($temp, '.'));
			
			#see if number is float or integer
			if($temp ne ""){
				if($temp - $_ < 0 || $temp - $_ > 0){
					if($self->{_dataType} ne "string"){
						$self->{_dataType} = "float";	
					}
				}
			}else{
				if($self->{_dataType} eq ""){
					$self->{_dataType} = "int";
				}
			}
			
			
		}else{
			$self->{_dataType} = "string";
		}
	}

	if($self->{_dataType} eq ""){
		$self->{_dataType} = "string";
	}
}

sub getName {
	my ($self) = @_;
	return $self->{_name};
}

sub setName {
	my ($self, $name) = @_;
	$self->{_name} = $name if defined $name;
}

sub getColNum {
	my ($self) = @_;
	return $self->{_colNum};
}

sub setColNum {
	my ($self, $colNum) = @_;
	$self->{_colNum} = $colNum if defined $colNum;
}

sub getDataType {
	my ($self) = @_;
	return $self->{_dataType};
}

sub setDataType {
	my ($self, $dataType) = @_;
	$self->{_dataType} = $dataType if defined $dataType;
}

sub getData {
	my ($self) = @_;
	return $self->{_data};
}

sub setData {
	my ($self, $data) = @_;
	$self->{_data} = $data if defined $data;
}

sub getError {
    my ($self) = @_;
    return $self->{_error};
}

1;