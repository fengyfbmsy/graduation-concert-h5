(function () {
  var eventInfo =
    "毕业音乐会\n" +
    "演出团体：咏恒合唱团 Cantare Sempre\n" +
    "时间：2026.06.21 周日 13:30-14:30\n" +
    "地点：北院学生活动中心（情人坡东南侧）\n" +
    "主办：清华大学咏恒合唱团\n" +
    "入场方式：面向全校师生开放，无需领票，可直接前往观看";

  var calendarInfo =
    "毕业音乐会 - 咏恒合唱团 Cantare Sempre\n" +
    "时间：2026.06.21 周日 13:30-14:30\n" +
    "地点：北院学生活动中心（情人坡东南侧）\n" +
    "备注：演出面向全校师生开放，无需领票，可直接前往观看。";

  var addressInfo = "北院学生活动中心 情人坡东南侧";

  var icsContent = [
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

  var body = document.body;
  var openButton = document.querySelector("[data-open]");
  var revealItems = document.querySelectorAll(".reveal");
  var toast = document.querySelector(".toast");
  var copyButton = document.querySelector("[data-copy]");
  var calendarButton = document.querySelector("[data-calendar]");
  var mapButton = document.querySelector("[data-map]");
  var posterButton = document.querySelector("[data-poster]");
  var copyCalendarButton = document.querySelector("[data-copy-calendar]");
  var downloadIcsButton = document.querySelector("[data-download-ics]");
  var copyAddressButton = document.querySelector("[data-copy-address]");
  var modalLayer = document.querySelector("[data-modal-layer]");
  var closeModalButtons = document.querySelectorAll("[data-close-modal]");
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

  function copyText(text, successMessage) {
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard
        .writeText(text)
        .then(function () {
          showToast(successMessage);
        })
        .catch(function () {
          fallbackCopy(text, successMessage);
        });
      return;
    }
    fallbackCopy(text, successMessage);
  }

  function fallbackCopy(text, successMessage) {
    var textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.setAttribute("readonly", "");
    textarea.style.position = "fixed";
    textarea.style.left = "-9999px";
    textarea.style.top = "0";
    document.body.appendChild(textarea);
    textarea.focus();
    textarea.select();

    try {
      document.execCommand("copy");
      showToast(successMessage);
    } catch (error) {
      showToast("复制失败，可长按文字手动复制");
    } finally {
      document.body.removeChild(textarea);
    }
  }

  function openModal(name) {
    if (!modalLayer) return;
    var panels = modalLayer.querySelectorAll("[data-modal]");
    panels.forEach(function (panel) {
      panel.hidden = panel.getAttribute("data-modal") !== name;
    });
    modalLayer.hidden = false;
    body.classList.add("modal-open");
  }

  function closeModal() {
    if (!modalLayer) return;
    modalLayer.hidden = true;
    body.classList.remove("modal-open");
  }

  if (copyButton) {
    copyButton.addEventListener("click", function () {
      copyText(eventInfo, "已复制活动信息");
    });
  }

  if (calendarButton) {
    calendarButton.addEventListener("click", function () {
      openModal("calendar");
    });
  }

  if (mapButton) {
    mapButton.addEventListener("click", function () {
      openModal("map");
    });
  }

  if (posterButton) {
    posterButton.addEventListener("click", function () {
      openModal("poster");
    });
  }

  if (copyCalendarButton) {
    copyCalendarButton.addEventListener("click", function () {
      copyText(calendarInfo, "已复制日历信息");
    });
  }

  if (copyAddressButton) {
    copyAddressButton.addEventListener("click", function () {
      copyText(addressInfo, "已复制地址");
    });
  }

  if (downloadIcsButton) {
    downloadIcsButton.addEventListener("click", function () {
      try {
        var blob = new Blob([icsContent], { type: "text/calendar;charset=utf-8" });
        var url = URL.createObjectURL(blob);
        var link = document.createElement("a");
        link.href = url;
        link.download = "graduation-concert.ics";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
        showToast("已尝试生成日历文件");
      } catch (error) {
        showToast("下载不稳定，可先复制日历信息");
      }
    });
  }

  closeModalButtons.forEach(function (button) {
    button.addEventListener("click", closeModal);
  });

  if (modalLayer) {
    modalLayer.addEventListener("click", function (event) {
      if (event.target === modalLayer) {
        closeModal();
      }
    });
  }

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
      closeModal();
    }
  });

  if (musicButton) {
    musicButton.addEventListener("click", function () {
      var isPlaying = musicButton.getAttribute("aria-pressed") === "true";
      musicButton.setAttribute("aria-pressed", String(!isPlaying));
      showToast(isPlaying ? "音乐已关闭" : "音乐开关已开启");
    });
  }
})();
