<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("config.php");

$email = $_POST['email'];
$password = sha1($_POST['password']);

$sqllogin = "SELECT * FROM tbl_users WHERE user_email = '$email' AND user_password = '$password'";
$result = $conn->query($sqllogin);

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $userlist = array();
        $userlist['user_id'] = $row['user_id'];
        $userlist['user_name'] = $row['user_name'];
        $userlist['user_email'] = $row['user_email'];
        $userlist['user_phone'] = $row['user_phone'];
        $userlist['chronic_condition'] = $row['chronic_condition'];
        $userlist['user_role'] = $row['user_role'];
        $userlist['user_datereg'] = $row['user_datereg'];
        
        $response = array('status' => 'success', 'data' => $userlist);
        sendJsonResponse($response);
    }
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>