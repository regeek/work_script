#!/usr/bin/perl

use strict;
use warnings;

####################
#main
####################
my $data_length = 0;
my @array_bin = ();
my $msg_01 = "改行データに変換しました";
my $msg_02 = "引数を指定して下さい";
my $msg_03 = "ファイルが存在しません";

if(@ARGV){
    foreach my $file(@ARGV){
        if( -f $file){
            print "何バイトで折り返しますか？ byte = ";
            $data_length = <STDIN>;
            chomp($data_length);

            if($data_length !~ /^\d+$/){
                print "数値を入力して下さい\n";
                exit(0);
            }

            ReadFile($file);
            WriteFile($file);
            print "FILENAME:$file, $msg_01\n";
        }
        else{
            print "FILENAME:$file, $msg_03\n";
        }
    }
}
else{
    print "$msg_02\n";
}

####################
#subroutine
####################
sub ReadFile{
    my $file = $_[0];
    my $cnt = 0;
    my $buf = "";

    open(IN,"+<",$file) or die "$!";
    binmode IN;

    while (read IN, $buf, $data_length) {
        my $data = unpack "a$data_length", $buf;
        $array_bin[$cnt] = $data;
        $cnt++;
    }

    close(IN);
}

sub WriteFile{
    my $file = $_[0];
    my $newline = "\n";
    my $buf = "";

    open(IN,"+>",$file) or die "$!";
    binmode IN;

    #改行挿入
    foreach my $data(@array_bin){
        $buf = pack "a$data_length  a1", $data, $newline;
        print IN $buf;
    }

    close(IN);
}

