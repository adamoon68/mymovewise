<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("config.php");

$user_id = $_POST['user_id'];
$exercise_name = $_POST['exercise_name']; // Can be a summary like "Full Body - Low Impact"
$type = $_POST['type']; // e.g., "Strength", "Cardio"

$sqlinsert = "INSERT INTO tbl_history (user_id, exercise_name, type) VALUES ('$user_id', '$exercise_name', '$type')";

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