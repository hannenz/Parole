using Gdk;
using Soup;

namespace Parole {

	/**
	  * Scrape a favicon form an URL
	  */
	public class FaviconScraper  {

		protected Pixbuf favicon = null;

		protected string url;

		protected string favicon_url;

		public FaviconScraper () {

			favicon = null;
		}

		public signal void scraped (Gdk.Pixbuf favicon);

		public async void scrape (string url) {

			// Add protocol, if not set
			if (!url.has_prefix ("http://") && !url.has_prefix ("https://")) {
				this.url = "http://%s".printf (url);
			}
			else {
				this.url = url;
			}

			debug (this.url);

			try {

				var session = new Session ();
				var message = new Message ("GET", this.url);

				session.send_message (message);

				var response = message.response_body.data;

				Regex regex = new Regex ("link.*rel.*shortcut.*href=\"(.*?)\"");
				MatchInfo matches;
				if (regex.match ((string)response, 0, out matches)) {
					favicon_url = matches.fetch (1);
					debug (favicon_url);

					// If str starts with http(s):// use as is
					if (!favicon_url.has_prefix ("http://") && !favicon_url.has_prefix ("https://")) {
						if (favicon_url.has_prefix ("//")) {
							// If str starts with //, strip it and use PROTO://str
							favicon_url = "http:" + favicon_url;
						}
						else {
							// Else use url/str
							favicon_url = "%s/%s".printf (this.url, favicon_url);
						}
					}

				}
				else {
					// /Try favicon.ico, favicon.png at url's root
					// e.g. url + "/favicon.ico", url + "/favicon.png"
				}

				debug (favicon_url);
				var file = File.new_for_uri (favicon_url);
				var file_stream = file.read ();
				var stream = new DataInputStream (file_stream);
				favicon = new Pixbuf.from_stream_at_scale (stream, 72, -1, true, null);
				scraped (favicon);
			}
			catch (Error e) {
				stderr.printf ("Error: %s\n", e.message);
			}
		}

		public Pixbuf get_favicon () {
			return favicon;
		}
	}
}

