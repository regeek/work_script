#!/usr/bin/perl

use strict;
use warnings;

####################
#main
####################
my $data_length = 10;
my @bin_array = ();
my $cnt_array = 0;
my $msg_01 = "改行データに変換しました";
my $msg_02 = "改行データに変換できません";
my $msg_03 = "提供データの改行が存在している可能性があります";
my $msg_04 = "引数を指定して下さい";
my $msg_05 = "ファイルが存在しません";

my $num_argv = @ARGV;
if($num_argv > 0){
    foreach my $file(@ARGV){
        if( -f $file){
            my $filesize = `ls -l $file | awk '{ print \$5 }'`;
            #shellの結果に改行が含まれるため、改行を削除
            chomp($filesize);

            if( ($filesize % $data_length) == 0 ){
                ReadFile($file);
                $cnt_array = @bin_array;
                WriteFile($file);

                print "FILENAME:$file, FILESIZE:$filesize byte, $msg_01\n";
            }
            else{
                print "FILENAME:$file, FILESIZE:$filesize byte, $msg_02, $msg_03\n";
            }
        }
        else{
            print "FILENAME:$file, $msg_05\n";
        }
    }
}
else{
    print "$msg_04\n";
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
        my ( $data) = unpack "a10", $buf;
        $bin_array[$cnt] = $data;

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

    #改行データに書き換え
    for(my $i=0;$i<$cnt_array;$i++){
        $buf = pack "a10 a1", $bin_array[$i], $newline;
        print IN $buf;
    }

    close(IN);
}

