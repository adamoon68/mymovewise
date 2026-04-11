<?php
include_once("config.php");

if (!isset($_POST['exercise_id']) || !isset($_POST['new_tag'])) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

$exercise_id = $_POST['exercise_id'];
$new_tag = $_POST['new_tag']; 

// Simple append logic for prototype
$sqlupdate = "UPDATE tbl_exercises SET tags = CONCAT(tags, ',', '$new_tag') WHERE exercise_id = '$exercise_id'";

if ($conn->query($sqlupdate) === TRUE) {
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