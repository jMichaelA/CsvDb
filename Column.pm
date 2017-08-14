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

	$self->{_dataType} = $dataType;
	$self->{_data} = @data;

	return $self;
}

#TODO implement
sub computeDataType {
	my $self = shift;
	print "gasp";
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

1;