<?php
include_once("config.php");

if (!isset($_POST['name']) || empty(trim($_POST['name']))) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Exercise name is required'));
    die();
}

$name = trim($_POST['name']);

$createTable = "CREATE TABLE IF NOT EXISTS tbl_deleted_exercises (
    deleted_id INT(11) NOT NULL AUTO_INCREMENT,
    exercise_name VARCHAR(255) NOT NULL UNIQUE,
    deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (deleted_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci";
$conn->query($createTable);

$conn->begin_transaction();

try {
    $deleteOverride = $conn->prepare("DELETE FROM tbl_exercises WHERE name = ?");
    $deleteOverride->bind_param("s", $name);
    if (!$deleteOverride->execute()) {
        throw new Exception($deleteOverride->error);
    }

    $insertDeleted = $conn->prepare(
        "INSERT INTO tbl_deleted_exercises (exercise_name) VALUES (?)
         ON DUPLICATE KEY UPDATE deleted_at = CURRENT_TIMESTAMP"
    );
    $insertDeleted->bind_param("s", $name);
    if (!$insertDeleted->execute()) {
        throw new Exception($insertDeleted->error);
    }

    $conn->commit();
    sendJsonResponse(array('status' => 'success'));
} catch (Exception $e) {
    $conn->rollback();
    sendJsonResponse(array('status' => 'failed', 'message' => $e->getMessage()));
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
