### [deprecated] I'm now using [FxLifeSheet](https://github.com/krausefx/fxlifesheet) for my mood tracking

---

# mood 

<img src="/assets/screenshot.png" width="300" align="right"/>

> If today were the last day of my life, would I want to do what I am about to do today?" And whenever the answer has been "No" for too many days in a row, I know I need to change something.

Steve Jobs

## Background

I've been a heavy user of [1 Second Everyday](https://1se.co/), where I created a very personal video of the full year for the last 730 days. (Check out a [public sample video here](https://www.youtube.com/watch?v=m_xlkC2DsSI))

One thing I noticed is that I associate the mood and happiness when seeing the videos, however, I know that this will slowly fade away as time passes.

I wanted a way to track my overall happiness and excitement in my life, allowing me to monitor, analyze and react to it. As Steve Jobs said, if you notice a downwards trend, it might be time to apply some changes to your life.

## How it works

It's a simple [Telegram Bot](https://core.telegram.org/bots) that will send you a message 3 times a day:

- One in the morning (I'd never reply to the bot before showering)
- One after lunch
- One when going to bed

You can always just text your bot a number, however, I know I'd forget it. That's why the bot sends you those reminders.

It then pulls up this really nice, optimized keyboard in Telegram, with a short description of what each number means.

If you forget to track a day, that's no big deal at all. The database is simple, it looks like this:

```ruby
@_db.create_table :moods do
  primary_key :id
  DateTime :time
  Integer :value
end
```

I decided not to store the information about breakfast, lunch and dinner, as it would make time zones more complex, as [I'm traveling quite a bit](https://whereisfelix.today).

## Future

### Graphs

I want a nice visualization page & dashboard for this. Maybe even just send a weekly and monthly summary via Telegram?

Right now, just send `/graph` to your bot to get your historic mood as a simple graph.

### Alerts

I want my bot to alert me when it detects a downwards trends. Similar to the stock trading approach, I was thinking of using the 7d average (7 days, 3 times a day => 21 data points). It's all relative, so if there is a downwards trends for 2 weeks, there probably is something bothering you

### Integration into 1SE

I usually edit the 1SE videos slightly to have "subtitles" for some of the important life events. Additionally, I throw in the classic [Every day of my life music](https://www.youtube.com/watch?v=m_xlkC2DsSI).

Additionally, with that data, I want to overlay my happiness level somehow, probably in the form of a graph, a bar, or a wave. Not sure yet, but I got 11 months to figure that out.

## How to use it

You'll have to setup a few things

- Create a Telegram bot using @BotFather and get the API key, and message ID with you
- Provide those values using `TELEGRAM_TOKEN` and `TELEGRAM_CHAT_ID`
  - To get the `TELEGRAM_CHAT_ID`, send a message to your bot and then access the following URL in your browser `https://api.telegram.org/bot[TELEGRAM_TOKEN]/getUpdates`. You'll see a message, and within that, the Chat ID to use
- And host it on any server, like Heroku, and use the Heroku scheduler feature to call `rake morning`, `rake noon` and `rake evening`
- Make sure the Heroku worker is enabled
