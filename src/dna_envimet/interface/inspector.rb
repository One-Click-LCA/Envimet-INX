module Envimet::EnvimetInx
	class Inspector
		attr_reader :dialog

		def initialize
      @dialog = create_dialog
    end 

		private 

		def create_dialog
			properties = { 
				dialog_title: "Inspector", 
				scrollable: true, 
				width: 800, 
				height: 600, 
				style: UI::HtmlDialog::STYLE_DIALOG
				}
			html = <<-HTML
				<html>
					<title>Inspector</title>
  				<link rel="icon" type="image/x-icon" href="res/icon/inx.png">
				<style>
					body {
						font-family: Arial, Helvetica, sans-serif;
					}
					p {
						font-size: 12px;
					}
					table {
						width:100%;
					}
					table, th, td {
						border: 2px solid #1C2833;
					border-collapse: collapse;
					}
					tr, td {
						padding: 10px;
						text-align: center;
						font-size: 14px;
						background-color: #17202A;
						color: #D5D8DC;
					}
				</style>
					<body>
					<h3>ENVI-Met inspector</h3>
						<table>
						<thead>
							<tr>
								<td>#️⃣ID</td>
								<td>🏠TYPE</td>
								<td>✏️DETAILS</td>
							</tr>
						</thead>
							<tbody id="envi-data">
							</tbody>
						</table>
						<div>
						<p id="counter"></p>
						<p>Select object on SKP canvas.</p>
						</div>
						<script>
							function insertData(message) {
								document.getElementById("envi-data").innerHTML = message;
							}
							function count(message) {
								document.getElementById("counter").innerText = message;
							}
						</script>
					</body>
				</html>
			HTML

			dialog = UI::HtmlDialog.new(properties)
			dialog.set_html(html)
			dialog.center
			dialog.set_on_closed { @dialog = create_dialog }
	    dialog
		end
	end # end Inspector

end # end Envimet::EnvimetInx
