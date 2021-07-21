#Script for scraping reviews
#Author: Tim Jonathan Rupp
#DISC applied project

from google_play_scraper import reviews_all
import json

#names of apps
apps = ["acrobat_reader", "any.do", "asana", "ayoa", "basecamp", "evernote", "forest", "github", "google_analytics",
        "google_drive", "google_keep", "google_tasks", "grammarly", "hootsuite", "ifttt", "notion", "pocket", "podio",
        "proofhub", "rescuetime", "slack", "ticktick", "todoist", "trello", "pdffiller", "quickbooks", "hotschedules",
        "duet_display", "noteshelf", "inkredible", "camscanner", "docusign", "artfulagenda", "dragonanywhere",
        "habitica", "productive", "outlook", "onedrive", "lastpass", "qrscanner"]

#package names for accessing app reviews
packages = ["com.adobe.reader", "com.anydo", "com.asana.app", "com.droptask.app", "com.basecamp.bc3", "com.evernote",
           "cc.forestapp", "com.github.android", "com.google.android.apps.giant", "com.google.android.apps.docs",
           "com.google.android.keep", "com.google.android.apps.tasks", "com.grammarly.android.keyboard",
           "com.hootsuite.droid.full", "com.ifttt.ifttt", "notion.id", "com.ideashower.readitlater.pro",
           "com.podio", "com.proofhub", "com.rescuetime.android", "com.Slack", "com.ticktick.task", "com.todoist",
           "com.trello", "com.pdffiller", "com.tsheets.android.hammerhead", "com.tdr3.hs.android",
           "com.kairos.duet", "com.fluidtouch.noteshelf2", "com.viettran.INKrediblePro", "com.intsig.camscanner",
           "com.docusign.ink", "com.artfulagenda.app", "com.nuance.dragonanywhere", "com.habitrpg.android.habitica",
           "com.apalon.to.do.list", "com.microsoft.office.outlook", "com.microsoft.skydrive", "com.lastpass.lpandroid",
            "com.gamma.scan"]

#loops over app packages and saves JSON with corresponding app name
for i in range(0, len(apps)):
  result = reviews_all(
    f'{packages[i]}',
    lang='en',
    country='us'
    )
  with open(f'reviews_JSON/{apps[i]}_reviews.json', 'w', encoding='utf-8') as f:
    json.dump(result, f, ensure_ascii=False, indent=4, sort_keys=True, default=str)
