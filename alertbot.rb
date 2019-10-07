require "discordrb"
require "json"
require "csv"

secrets=JSON.parse(File.read("secrets.json"))
notifications=CSV.read("notifications.csv")[0]

token=secrets["token"]

$text_channel_id=secrets["text_channel_id"]to_i

$voice_channel_id=secrets["voice_channel_id"]to_i

WHITE_CHECK_MARK="\u2705"

announcer_id=secrets["announcer_id"]

def calculate_missing(bot,event)
	missing=[]
	attending=event.message.reacted_with(WHITE_CHECK_MARK)
	present=bot.channel($voice_channel_id).users
	attending.each do |user|
		missing.push(user) if !present.include?(user)
	end

	return missing
end

bot=Discordrb::Bot.new token:token

bot.message(start_with:"Your event") do |event|

	if event.message.author.id==announcer_id
		sleep(30)

		missing=calculate_missing(bot,event)
		missing.each do |user|
			bot.voice_state_update(from:user,channel:$voice_channel_id) do |event|
				bot.channel($text_channel_id).send_message user.mention + "Welcome to the chat"
			end
		end

		while !missing.empty?
			missing.each do |victim|
				bot.channel($text_channel_id).send_message victim.mention + " " + notifications.sample
			end
			sleep(2)

			missing=calculate_missing(bot,event)
		end
	end

end

bot.run