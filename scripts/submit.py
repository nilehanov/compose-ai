#!/usr/bin/env python3
"""Compose: AI Email Draft -- App Store Connect submission script."""
import json, time, datetime, sys
from pathlib import Path
import jwt, requests

APP_ID, BUNDLE_ID = "6762165245", "com.nilehanov.compose"
_KEY_PATH = Path.home() / "private_keys" / "api_key.json"
_BASE = "https://api.appstoreconnect.apple.com/v1"
_META = Path(__file__).resolve().parent.parent / "fastlane" / "metadata" / "en-US"
_VERBS = {"get": requests.get, "post": requests.post, "patch": requests.patch}

class Submitter:
    """Handles JWT auth, API calls, and all 9 submission steps."""
    def __init__(self):
        with open(_KEY_PATH) as f:
            self._key = json.load(f)
        self.token = self._mint()
    def _mint(self):
        now = datetime.datetime.now(datetime.timezone.utc)
        return jwt.encode(
            {"iss": self._key["issuer_id"], "iat": int(now.timestamp()),
             "exp": int((now + datetime.timedelta(minutes=20)).timestamp()),
             "aud": "appstoreconnect-v1"},
            self._key["key"], algorithm="ES256", headers={"kid": self._key["key_id"]})
    def refresh(self):
        self.token = self._mint()
    def api(self, verb, path, body=None):
        kw = {"headers": {"Authorization": f"Bearer {self.token}", "Content-Type": "application/json"}}
        if body is not None:
            kw["json"] = body
        r = _VERBS[verb](f"{_BASE}{path}", **kw)
        if not r.ok:
            print(f"{verb.upper()} {path} failed: {r.status_code}\n{r.text}")
        r.raise_for_status()
        return r.json()
    @staticmethod
    def _meta(name):
        return (_META / name).read_text().strip()
    def update_app_info(self):
        print("[1/9] Updating app info (category, privacy URL)")
        info_id = self.api("get", f"/apps/{APP_ID}/appInfos")["data"][0]["id"]
        self.api("patch", f"/appInfos/{info_id}", {"data": {
            "type": "appInfos", "id": info_id,
            "relationships": {"primaryCategory": {"data": {"type": "appCategories", "id": "PRODUCTIVITY"}}}}})
        print("  Category -> PRODUCTIVITY")
        locs = self.api("get", f"/appInfos/{info_id}/appInfoLocalizations")
        if locs["data"]:
            lid = locs["data"][0]["id"]
            self.api("patch", f"/appInfoLocalizations/{lid}", {"data": {
                "type": "appInfoLocalizations", "id": lid,
                "attributes": {"privacyPolicyUrl": "https://nilehanov.github.io/compose-ai/privacy-policy.html"}}})
            print("  Privacy policy URL set")
        return info_id
    def update_version_metadata(self):
        print("[2/9] Updating version metadata")
        resp = self.api("get", f"/apps/{APP_ID}/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION&limit=1")
        if not resp["data"]:
            resp = self.api("get", f"/apps/{APP_ID}/appStoreVersions?limit=1")
        vid = resp["data"][0]["id"]
        print(f"  Version ID: {vid}")
        self.api("patch", f"/appStoreVersions/{vid}", {"data": {
            "type": "appStoreVersions", "id": vid, "attributes": {"copyright": "2026 Nile Hanov"}}})
        locs = self.api("get", f"/appStoreVersions/{vid}/appStoreVersionLocalizations")
        if locs["data"]:
            lid, site = locs["data"][0]["id"], "https://nilehanov.github.io/compose-ai/"
            self.api("patch", f"/appStoreVersionLocalizations/{lid}", {"data": {
                "type": "appStoreVersionLocalizations", "id": lid,
                "attributes": {
                    "description": self._meta("description.txt"), "keywords": self._meta("keywords.txt"),
                    "supportUrl": site, "marketingUrl": site,
                    "promotionalText": self._meta("promotional_text.txt")}}})
            print("  Localization updated")
        return vid
    def set_age_rating(self, info_id):
        print("[3/9] Setting age rating (all NONE)")
        try:
            ar_id = self.api("get", f"/appInfos/{info_id}/ageRatingDeclaration")["data"]["id"]
            attrs = {k: "NONE" for k in [
                "alcoholTobaccoOrDrugUseOrReferences", "contests", "gamblingSimulated",
                "medicalOrTreatmentInformation", "profanityOrCrudeHumor", "sexualContentOrNudity",
                "horrorOrFearThemes", "matureOrSuggestiveThemes",
                "violenceCartoonOrFantasy", "violenceRealisticProlonged", "violenceRealistic"]}
            attrs.update(gamblingAndContests=False, unrestrictedWebAccess=False, seventeenPlus=False)
            self.api("patch", f"/ageRatingDeclarations/{ar_id}", {"data": {
                "type": "ageRatingDeclarations", "id": ar_id, "attributes": attrs}})
            print("  Done")
        except Exception as e:
            print(f"  Skipped: {e}")
    def set_content_rights(self):
        print("[4/9] Setting content rights")
        try:
            self.api("patch", f"/apps/{APP_ID}", {"data": {
                "type": "apps", "id": APP_ID,
                "attributes": {"contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT"}}})
            print("  Done")
        except Exception as e:
            print(f"  Skipped: {e}")
    def set_price(self):
        print("[5/9] Setting price to $5.99")
        try:
            pts = self.api("get", f"/apps/{APP_ID}/appPricePoints?filter[territory]=USA&limit=200")
            pid = next((p["id"] for p in pts["data"]
                         if p.get("attributes", {}).get("customerPrice") == "5.99"), None)
            if not pid:
                print("  $5.99 price point not found; set manually")
                return
            self.api("post", "/appPriceSchedules", {
                "data": {"type": "appPriceSchedules", "relationships": {
                    "app": {"data": {"type": "apps", "id": APP_ID}},
                    "baseTerritory": {"data": {"type": "territories", "id": "USA"}},
                    "manualPrices": {"data": [{"type": "appPrices", "id": "${p1}"}]}}},
                "included": [{"type": "appPrices", "id": "${p1}", "relationships": {
                    "appPricePoint": {"data": {"type": "appPricePoints", "id": pid}}}}]})
            print(f"  Done (point: {pid})")
        except Exception as e:
            print(f"  Skipped: {e}")
    def wait_for_build(self, max_wait=600):
        print("[6/9] Waiting for build to become VALID")
        deadline = time.time() + max_wait
        while time.time() < deadline:
            builds = self.api("get", f"/builds?filter[app]={APP_ID}&sort=-uploadedDate&limit=1")
            if builds["data"]:
                b, state = builds["data"][0], builds["data"][0]["attributes"]["processingState"]
                print(f"  Build {b['attributes']['version']}: {state}")
                if state == "VALID":
                    return b["id"]
                if state == "INVALID":
                    print("  ERROR: Build is INVALID!")
                    return None
            time.sleep(15)
        print("  Timed out")
        return None
    def set_export_compliance(self, bid):
        print(f"[7/9] Setting export compliance for {bid}")
        try:
            self.api("patch", f"/builds/{bid}", {"data": {
                "type": "builds", "id": bid, "attributes": {"usesNonExemptEncryption": False}}})
            print("  Done")
        except Exception as e:
            print(f"  Skipped: {e}")
    def assign_build(self, vid, bid):
        print(f"[8/9] Assigning build {bid} to version {vid}")
        self.api("patch", f"/appStoreVersions/{vid}", {"data": {
            "type": "appStoreVersions", "id": vid,
            "relationships": {"build": {"data": {"type": "builds", "id": bid}}}}})
        print("  Done")
    def submit_for_review(self, vid):
        print(f"[9/9] Submitting version {vid} for review")
        try:
            self.api("post", "/appStoreVersionSubmissions", {"data": {
                "type": "appStoreVersionSubmissions",
                "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": vid}}}}})
            print("  Submitted!")
        except Exception:
            try:
                self.api("post", "/reviewSubmissions", {"data": {
                    "type": "reviewSubmissions", "attributes": {"platform": "IOS"},
                    "relationships": {"app": {"data": {"type": "apps", "id": APP_ID}}}}})
                print("  Submitted (v2)!")
            except Exception as e2:
                print(f"  Failed: {e2} -- submit manually from App Store Connect")
    def run(self):
        print(f"=== Compose: AI Email Draft -- Submission ===\nApp: {APP_ID} ({BUNDLE_ID})\n")
        info_id = self.update_app_info()
        vid = self.update_version_metadata()
        self.set_age_rating(info_id)
        self.set_content_rights()
        self.set_price()
        bid = self.wait_for_build()
        if bid:
            self.refresh()
            self.set_export_compliance(bid)
            self.assign_build(vid, bid)
            self.submit_for_review(vid)
        else:
            print(f"\nNo valid build. Re-run later.")
            print(f"Check: https://appstoreconnect.apple.com/apps/{APP_ID}/testflight")
        print(f"\n=== Done ===\nApp Store Connect: https://appstoreconnect.apple.com/apps/{APP_ID}")
        print(f"Privacy: https://appstoreconnect.apple.com/apps/{APP_ID}/distribution/privacy")
        print("IMPORTANT: Visit the privacy page above and set 'Data Not Collected'")


if __name__ == "__main__":
    Submitter().run()
