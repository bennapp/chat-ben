namespace :user_channels do
  desc "TODO"

  task build: :environment do
    channel_data = [
      { bin_id: 93, name: "tar89" },
      { bin_id: 94, name: "Walsh" },
      { bin_id: 96, name: "Parker" },
      { bin_id: 97, name: "NakedCollinmmSexy" },
      { bin_id: 99, name: "keltar" },
      { bin_id: 100, name: "Drew" },
      { bin_id: 101, name: "pfdotter" },
      { bin_id: 104, name: "nwags" },
      { bin_id: 107, name: "jake" },
      { bin_id: 111, name: "napes" },
      { bin_id: 112, name: "KARP" },
      { bin_id: 113, name: "that_guy" },
      { bin_id: 114, name: "danmero" },
      { bin_id: 115, name: "Drakon" },
      { bin_id: 116, name: "ashalan" },
      { bin_id: 117, name: "Rachface" },
    ]

    channel_data.each do |data|
      Bin.find(data[:bin_id]).update_attribute(:user_id, User.where(name: data[:name]).first.id)
    end
  end
end