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
$from = "mailmon@srce.hr";

// Delete all messages from inbox  //

// open IMAP connection
//$mbox = imap_open("{server.srce.hr:port/imap/ssl}INBOX", "user", "password") or die("0");
$mbox = imap_open("{{$host}:993/imap/ssl}INBOX", $user, $pass) or die("0");
// calculate number of messages
$mbox_state=imap_check($mbox);
// mark all messages for deletion
if($mbox_state) {
                //process messages one by one
                for($msgnum=1;$msgnum<=$mbox_state->Nmsgs;$msgnum++) {
                    //delete this message from server
                    imap_delete($mbox, $msgnum);
                }
}

// expunge mails
imap_expunge($mbox);
// close IMAP connection
//imap_close($mbox);
imap_close($mbox,CL_EXPUNGE);


// Send message //

// open IMAP connection  
$mbox = imap_open("{{$host}:993/imap/ssl}INBOX", $user, $pass) or die("0"); 
// send message
$send = imap_mail("$user@srce.hr","Test email","Sys-mon proba za funkcionalni test mail sustava","From: $from\n");
// returns TRUE (1) if mail is sent correctly, ??? otherwise
echo $send;
// close IMAP connection
imap_close($mbox); 
?>
