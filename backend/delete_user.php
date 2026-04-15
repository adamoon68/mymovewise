<?php
include_once("config.php");

if (!isset($_POST['user_id']) || !isset($_POST['admin_id'])) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Missing parameters'));
    die();
}

$userId = $_POST['user_id'];
$adminId = $_POST['admin_id'];

if ($userId == $adminId) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'You cannot delete your own admin account.'));
    die();
}

$stmt = $conn->prepare("SELECT user_role FROM tbl_users WHERE user_id = ?");
$stmt->bind_param("i", $userId);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'User not found'));
    die();
}

$user = $result->fetch_assoc();
if ($user['user_role'] === 'admin') {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Admin accounts cannot be deleted here.'));
    die();
}

$conn->begin_transaction();

try {
    $deleteHistory = $conn->prepare("DELETE FROM tbl_history WHERE user_id = ?");
    $deleteHistory->bind_param("i", $userId);
    if (!$deleteHistory->execute()) {
        throw new Exception($deleteHistory->error);
    }

    $deleteUser = $conn->prepare("DELETE FROM tbl_users WHERE user_id = ?");
    $deleteUser->bind_param("i", $userId);
    if (!$deleteUser->execute()) {
        throw new Exception($deleteUser->error);
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
