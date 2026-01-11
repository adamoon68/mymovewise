<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("config.php");

$name = $_POST['name'];
$description = $_POST['description'];
$type = $_POST['type']; // e.g., "Strength", "Cardio"
$tags = $_POST['tags']; // e.g., "Low Impact", "High Impact"

$sqlinsert = "INSERT INTO tbl_exercises (name, description, type, tags) VALUES ('$name', '$description', '$type', '$tags')";

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