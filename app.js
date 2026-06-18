(function () {
  var eventInfo =
    "毕业音乐会\n" +
    "演出团体：咏恒合唱团 Cantare Sempre\n" +
    "时间：2026.06.21 周日 13:30-14:30\n" +
    "地点：北院学生活动中心（情人坡东南侧）\n" +
    "主办：清华大学咏恒合唱团\n" +
    "入场方式：面向全校师生开放，无需领票，可直接前往观看";

  var body = document.body;
  var openButton = document.querySelector("[data-open]");
  var revealItems = document.querySelectorAll(".reveal");
  var toast = document.querySelector(".toast");
  var copyButton = document.querySelector("[data-copy]");
  var calendarButton = document.querySelector("[data-calendar]");
  var musicButton = document.querySelector(".music-toggle");

  function showToast(message) {
    if (!toast) return;
    toast.textContent = message;
    window.clearTimeout(showToast.timer);
    showToast.timer = window.setTimeout(function () {
      toast.textContent = "";
    }, 2200);
  }

  function openInvite() {
    if (body.classList.contains("invite-open")) return;
    body.classList.add("invite-open");

    window.setTimeout(function () {
      body.classList.remove("invite-locked");
    }, 1800);
  }

  if (openButton) {
    openButton.addEventListener("click", openInvite);
  }

  if ("IntersectionObserver" in window) {
    var observer = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.18, rootMargin: "0px 0px -42px 0px" }
    );

    revealItems.forEach(function (item) {
      observer.observe(item);
    });
  } else {
    revealItems.forEach(function (item) {
      item.classList.add("is-visible");
    });
  }

  if (copyButton) {
    copyButton.addEventListener("click", function () {
      if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard
          .writeText(eventInfo)
          .then(function () {
            showToast("活动信息已复制");
          })
          .catch(function () {
            fallbackCopy(eventInfo);
          });
        return;
      }
      fallbackCopy(eventInfo);
    });
  }

  function fallbackCopy(text) {
    var textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.setAttribute("readonly", "");
    textarea.style.position = "fixed";
    textarea.style.left = "-9999px";
    document.body.appendChild(textarea);
    textarea.select();

    try {
      document.execCommand("copy");
      showToast("活动信息已复制");
    } catch (error) {
      showToast("复制失败，可长按文字手动复制");
    } finally {
      document.body.removeChild(textarea);
    }
  }

  if (calendarButton) {
    calendarButton.addEventListener("click", function () {
      var ics = [
        "BEGIN:VCALENDAR",
        "VERSION:2.0",
        "PRODID:-//Cantare Sempre//Graduation Concert//CN",
        "BEGIN:VEVENT",
        "UID:graduation-concert-20260621@cantare-sempre",
        "DTSTAMP:20260618T000000Z",
        "DTSTART:20260621T053000Z",
        "DTEND:20260621T063000Z",
        "SUMMARY:毕业音乐会 - 咏恒合唱团 Cantare Sempre",
        "LOCATION:北院学生活动中心（情人坡东南侧）",
        "DESCRIPTION:演出面向全校师生开放，无需领票，可直接前往观看。",
        "END:VEVENT",
        "END:VCALENDAR"
      ].join("\r\n");

      var blob = new Blob([ics], { type: "text/calendar;charset=utf-8" });
      var url = URL.createObjectURL(blob);
      var link = document.createElement("a");
      link.href = url;
      link.download = "graduation-concert.ics";
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
      showToast("日历文件已生成");
    });
  }

  if (musicButton) {
    musicButton.addEventListener("click", function () {
      var isPlaying = musicButton.getAttribute("aria-pressed") === "true";
      musicButton.setAttribute("aria-pressed", String(!isPlaying));
      showToast(isPlaying ? "音乐已关闭" : "音乐开关已开启");
    });
  }
})();
