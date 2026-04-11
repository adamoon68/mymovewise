<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("config.php");

$name = $_POST['name'];
$email = $_POST['email'];
$password = sha1($_POST['password']);
$phone = $_POST['phone'];
// Specific to MoveWise: Users must declare conditions for the safety filter
$condition = $_POST['chronic_condition']; 

$sqlinsert = "INSERT INTO tbl_users (user_name, user_email, user_password, user_phone, chronic_condition, user_role) VALUES ('$name', '$email', '$password', '$phone', '$condition', 'user')";

if ($conn->query($sqlinsert) === TRUE) {
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
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