-- ✅ Script gửi Webhook AFK Reward - dùng với setting
-- Cần truyền bảng setting = { ['Webhook Url'] = "..." }

return function(setting)
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    -- Lấy URL từ setting
    local WebhookURL = setting and setting["Webhook Url"]
    if not WebhookURL then
        warn("[❌] Thiếu Webhook Url trong setting!")
        return
    end

    -- Đợi GUI nhận thưởng xuất hiện
    local rewardGui
    repeat
        rewardGui = Player:FindFirstChild("PlayerGui") and Player.PlayerGui:FindFirstChild("CountDown")
        task.wait(1)
    until rewardGui and rewardGui:FindFirstChild("Frame")

    local receivedFrame = rewardGui.Frame:FindFirstChild("Recieved")
    if not receivedFrame then
        warn("[❌] Không tìm thấy khung nhận thưởng!")
        return
    end

    print("[✅] Đã tìm thấy giao diện nhận thưởng AFK!")

    local lastItemSent = ""

    -- Theo dõi phần tử mới trong ScrollingFrame
    local function onChildAdded(child)
        task.wait(0.2)
        local rewardNameLabel = child:FindFirstChild("RewardName")
        if rewardNameLabel and rewardNameLabel:IsA("TextLabel") then
            local itemName = rewardNameLabel.Text
            if itemName and itemName ~= lastItemSent then
                lastItemSent = itemName

                local data = {
                    username = "AFK Rewards Bot",
                    embeds = {{
                        title = "🎁 Nhận được vật phẩm mới!",
                        description = "**" .. itemName .. "**",
                        color = 65280
                    }}
                }

                local success, err = pcall(function()
                    syn.request({
                        Url = WebhookURL,
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json"
                        },
                        Body = HttpService:JSONEncode(data)
                    })
                end)

                if success then
                    print("[✅] Đã gửi item về Webhook:", itemName)
                else
                    warn("[❌] Webhook lỗi:", err)
                end
            end
        end
    end

    -- Bắt đầu theo dõi các phần tử nhận thưởng
    local scrollingFrame = receivedFrame:FindFirstChild("ScrollingFrame")
    if scrollingFrame then
        scrollingFrame.ChildAdded:Connect(onChildAdded)
        print("[👀] Đang theo dõi item trong khu AFK...")
    else
        warn("[❌] Không tìm thấy ScrollingFrame trong Received!")
    end
end
