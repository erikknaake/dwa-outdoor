import countdown from "countdown";

/**
 * Enables countdowns
 *
 * Example HTML: <span class="count-down" data-countdown-date="2020-02-29T12:30:30.120+00:00"></span>
 *
 * Use Extended ISO date string format.
 */
export function decorateHooksWithCountdown(Hooks) {
    let countdowns = [];

    function countdownHook(self) {
        const countDownElement = document.getElementById(self.el.id);
        const defaultCountDown = countDownElement.classList.contains("default")

        const countDownDateTime = new Date(countDownElement.getAttribute("data-countdown-date"));
        const countDownDateTimeUTC = Date.UTC(countDownDateTime.getUTCFullYear(), countDownDateTime.getUTCMonth(), countDownDateTime.getUTCDate(),
            countDownDateTime.getUTCHours(), countDownDateTime.getUTCMinutes(), countDownDateTime.getUTCSeconds(), countDownDateTime.getUTCMilliseconds());

        if (defaultCountDown) {
             countdowns[self.el.id] = countdown(countDownDateTimeUTC, (timeSpan) => {
                if (countDownDateTimeUTC < new Date()) location.reload();
                countDownElement.innerHTML = timeSpan;
            });
        } else {
            countdowns[self.el.id] = countdown(countDownDateTimeUTC, (timeSpan) => {
                let hours = "00", minutes = "00", seconds = "00";
                const localeConfig = {
                    minimumIntegerDigits: 2,
                    useGrouping: false
                };

                if (countDownDateTimeUTC < new Date()) {
                    self.pushEvent("countdown_over", {countdown_datetime: countDownDateTimeUTC});
                }

                if (countDownDateTimeUTC > new Date()) {
                    hours = timeSpan.days > 0
                        ? timeSpan.hours + (timeSpan.days * 24)
                        : timeSpan.hours

                    hours = hours.toLocaleString('en-US', localeConfig)
                    minutes = timeSpan.minutes.toLocaleString('en-US', localeConfig)
                    seconds = timeSpan.seconds.toLocaleString('en-US', localeConfig)
                }

                countDownElement.innerHTML = `<span>${hours}:</span><span>${minutes}:</span><span>${seconds}</span>`;
            }, countdown.HOURS & countdown.MINUTES & countdown.SECONDS);
        }
    }

    Hooks.Countdown = {
        mounted() {
            let self = this;
            countdownHook(self);
        },

        updated() {
            let self = this;
            window.clearInterval(countdowns[self.el.id]);
            countdownHook(self);
        }
    }

}

