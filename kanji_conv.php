<?php
$inputFile  = 'kanji7_font_1350.bin';
$outputFile = 'kanji7_font_1350_v2.bin';

$data = unpack("C*", file_get_contents($inputFile));
$fp = fopen($outputFile, 'wb');
dot7compress($fp, $data);
fclose($fp);

function dot7compress($fp, array $data) {
    for ($i = 1; $i <= count($data); $i += 7) {
        $c1 = $data[$i];
        $c2 = $data[$i + 1];
        $c3 = $data[$i + 2];
        $c4 = $data[$i + 3];
        $c5 = $data[$i + 4];
        $c6 = $data[$i + 5];
        $c7 = $data[$i + 6];

        $c1 = ($c7 & 0x20) ? $c1  | 0x80 : $c1;
        $c2 = ($c7 & 0x10) ? $c2  | 0x80 : $c2;
        $c3 = ($c7 & 0x08) ? $c3  | 0x80 : $c3;
        $c4 = ($c7 & 0x04) ? $c4  | 0x80 : $c4;
        $c5 = ($c7 & 0x02) ? $c5  | 0x80 : $c5;
        $c6 = ($c7 & 0x01) ? $c6  | 0x80 : $c6;

        fwrite($fp, pack("C*", $c1, $c2, $c3, $c4, $c5, $c6));
    }
}

function dot11compress($fp, array $data) {
    for ($i = 1; $i <= count($data); $i += 11) {
        $c1  = $data[$i];
        $c2  = $data[$i + 1];
        $c3  = $data[$i + 2];
        $c4  = $data[$i + 3];
        $c5  = $data[$i + 4];
        $c6  = $data[$i + 5];
        $c7  = $data[$i + 6];
        $c8  = $data[$i + 7];
        $c9  = $data[$i + 8];
        $c10 = $data[$i + 9];
        $c11 = $data[$i + 10];

        $c4  = ($c11 & 0x40) ? $c4  | 0x80 : $c4;
        $c5  = ($c11 & 0x20) ? $c5  | 0x80 : $c5;
        $c6  = ($c11 & 0x10) ? $c6  | 0x80 : $c6;
        $c7  = ($c11 & 0x08) ? $c7  | 0x80 : $c7;
        $c8  = ($c11 & 0x04) ? $c8  | 0x80 : $c8;
        $c9  = ($c11 & 0x02) ? $c9  | 0x80 : $c9;
        $c10 = ($c11 & 0x01) ? $c10 | 0x80 : $c10;

        fwrite($fp, pack("C*", $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $c10));
    }
}

