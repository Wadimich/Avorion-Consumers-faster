package.path = package.path .. ";data/scripts/lib/?.lua;data/scripts/entity/merchants/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua;"

include("stringutility")
-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace FasterConsumer
FasterConsumer = include("consumer")

FasterConsumer.consumerName = "Faster Consumer"
FasterConsumer.consumerIcon = "data/textures/icons/faster-habitat.png"
FasterConsumer.consumedGoods = {
    "Water",
    "Wheat",
}

function FasterConsumer.initializationFinished()
    -- use the initilizationFinished() function on the client since in initialize() we may not be able to access Sector scripts on the client
    if onClient() then
        local ok, r = Sector():invokeFunction("radiochatter", "addSpecificLines", Entity().id.string,
                {
                    "No private visits for block ${R} today." % _t,
                    "Apartment inspections will begin shortly after the wake-up signal." % _t,
                    "The bad news: In areas ${R} and ${LN2} the warm water isn't working today. The good news: cold showers wake you up and increase productivity!" % _t,
                    "Today's job offers: habitat command is looking for ${N} doctors and ${N2} plumbers." % _t,
                    "We're asking all residents to dry their clothes only in the designated areas." % _t,
                    "Our restaurants are open all the time for you."%_t,
                    "Visit our parks. Only the best weather thanks to our latest software."%_t,
                    "When have you last seen animals outside of a cage?"%_t,
                    "Visit the biotope and get a home-picked apple! Included in the ticket price."%_t,
                    "Visit us and get a home-picked apple."%_t,
                    "We got all new squatels and kliefs! During a visit to the zoo you can have a look at them."%_t,
                    "Oh no! I've lost my ship! I guess I'll have to walk home now."%_t,
                    "What? Drunk? Me? Never."%_t,
                    "Recreational gambling - the best in the sector!"%_t,
                    "We offer over ${N3}0 different games!"%_t,
                    "The first round is free!"%_t,
                    "Come to our casino, we have the most modern games and you might even win!"%_t,
                })
    end
end

function FasterConsumer.useUpBoughtGoods(timeStep)
    if not FasterConsumer.trader.useUpGoodsEnabled then
        return
    end

    local tickTime = 60

    FasterConsumer.trader.useTimeCounter = FasterConsumer.trader.useTimeCounter + timeStep
    if FasterConsumer.trader.useTimeCounter > tickTime then
        FasterConsumer.trader.useTimeCounter = FasterConsumer.trader.useTimeCounter - tickTime

        for i = 1, 5 do
            local good = FasterConsumer.trader.boughtGoods[math.random(1, #FasterConsumer.trader.boughtGoods)]

            if not good then
                goto continue
            end

            local inStock = FasterConsumer.trader:getNumGoods(good.name)
            local amount = math.random(math.max(inStock * 0.1, 20), math.max(inStock * 0.25, 100))

            amount = math.min(inStock, amount)

            if amount == 0 then
                goto continue
            end

            FasterConsumer.trader:decreaseGoods(good.name, amount)

            local faction = Faction()
            if faction then
                local station = Entity()
                local price = FasterConsumer.trader:getBuyPrice(good.name)
                local received = price * 1.10 * amount

                local x, y = Sector():getCoordinates()
                local description = Format("\\s(%1%:%2%) %3%'s population consumed %4% %5% and paid you ¢%6% for it (¢%7% profit)." % _T,
                        x, y,
                        station.name,
                        math.floor(amount),
                        good:pluralForm(math.floor(amount)),
                        createMonetaryString(received),
                        createMonetaryString(price * amount * 0.10))

                faction:receive(description, received)
                FasterConsumer.trader.stats.moneyGainedFromGoods = FasterConsumer.trader.stats.moneyGainedFromGoods + received
            end

            break

            :: continue ::
        end
    end
end
