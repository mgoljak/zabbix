<?php 
// supress PHP output
error_reporting(0);

// check number of arguments
if ($argc < 3 ) {
    die("0");
//    die('Missing arguments!');
}

//var_dump($argv);
$host = $argv[1];
$user = $argv[2];
$pass = $argv[3];

// Get messages from inbox //

// open IMAP connection  
$mbox = imap_open("{{$host}:993/imap/ssl}INBOX", $user, $pass) or die("0");

// calculate number of messages  
$mbox_state=imap_check($mbox); 

// Second check
if ($mbox_state->Nmsgs != "1") {

   // Wait 3 minutes
   sleep(180);

   // calculate number of messages
   $mbox_state=imap_check($mbox);
}

// report number of messages
echo $mbox_state->Nmsgs;

// close IMAP connection
imap_close($mbox); 
?>
