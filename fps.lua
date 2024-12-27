-- Sử dụng getgenv() để lưu trữ cấu hình toàn cục
getgenv().config = {
    maxFPS = 30,          -- Giới hạn FPS tối đa
    visibleRange = 100,   -- Phạm vi hiển thị đối tượng
    objectName = "Part", -- Tên đối tượng (để "" nếu muốn áp dụng cho tất cả đối tượng)
}

-- Lấy giá trị từ bảng config toàn cục
local config = getgenv().config
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Tính toán thời gian giữa các frame dựa trên maxFPS
local frameTime = 1 / config.maxFPS
local lastUpdateTime = 0  -- Thời gian cập nhật lần trước

-- Hàm kiểm tra xem đối tượng có trong phạm vi camera không
local function isObjectVisible(part)
    local inRange = (camera.CFrame.Position - part.Position).Magnitude
    return inRange < config.visibleRange  -- Kiểm tra phạm vi hiển thị từ config
end

-- Quản lý hiển thị từng đối tượng
local function manageObjectVisibility()
    for _, object in ipairs(workspace:GetChildren()) do
        if object:IsA("BasePart") and (config.objectName == "" or object.Name == config.objectName) then
            if isObjectVisible(object) then
                if not object.Parent then
                    local clone = object:Clone() -- Clone đối tượng nếu không có trong workspace
                    clone.Parent = workspace
                end
            else
                if object.Parent then
                    object:Destroy() -- Xóa đối tượng khi không cần thiết
                end
            end
        end
    end
end

-- Tối ưu hóa với sự kiện và FPS cap
game:GetService("RunService").Heartbeat:Connect(function()
    local currentTime = tick()

    -- Kiểm tra xem thời gian đã trôi qua đủ để cập nhật chưa
    if currentTime - lastUpdateTime >= frameTime then
        lastUpdateTime = currentTime
        -- Quản lý hiển thị tất cả đối tượng
        manageObjectVisibility()
    end
end)

-- Hàm để giảm tải CPU khi người chơi di chuyển
local function onPlayerMove()
    if player.Character then
        local characterPosition = player.Character.HumanoidRootPart.Position
        -- Giảm tải việc tính toán bằng cách chỉ tính khi cần thiết
        if (camera.CFrame.Position - characterPosition).Magnitude < 50 then
            -- Thực hiện các công việc nhẹ nhàng nếu player gần camera
        end
    end
end

-- Kết nối sự kiện người chơi di chuyển
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Running:Connect(onPlayerMove)
end)
