import os
import yaml
from flask import Flask, render_template_string, request, redirect, url_for, send_from_directory

app = Flask(__name__)

TEAMS_YAML_PATH = os.path.join(os.path.dirname(__file__), '../teams/resources.yaml')


@app.route('/static/<path:filename>')
def static_files(filename):
    return send_from_directory(os.path.join(os.path.dirname(__file__), 'images'), filename)


FORM_HTML = '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Onboard a New Team</title>
  <link href="https://fonts.googleapis.com/css?family=Roboto:400,700&display=swap" rel="stylesheet">
  <style>
    body {
      background: #f4f6f8;
      font-family: 'Roboto', Arial, sans-serif;
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100vh;
      margin: 0;
    }
    .form-container {
      background: #fff;
      padding: 2.5rem 2rem 2rem 2rem;
      border-radius: 12px;
      box-shadow: 0 4px 24px rgba(0,0,0,0.08);
      min-width: 350px;
      max-width: 400px;
    }
    h2 {
      margin-top: 0;
      margin-bottom: 1.5rem;
      font-weight: 700;
      color: #2d3748;
      text-align: center;
      letter-spacing: 0.5px;
    }
    label {
      display: block;
      margin-bottom: 0.5rem;
      color: #4a5568;
      font-weight: 500;
    }
    input[type="text"], input[type="email"] {
      width: 93%;
      padding: 0.7rem;
      margin-bottom: 1.2rem;
      border: 1px solid #cbd5e0;
      border-radius: 6px;
      font-size: 1rem;
      background: #f7fafc;
      transition: border-color 0.2s;
    }
    input[type="text"]:focus, input[type="email"]:focus {
      border-color: #3182ce;
      outline: none;
      background: #fff;
    }
    .checkbox-group {
      margin-bottom: 1.2rem;
    }
    .checkbox-group label {
      display: inline-block;
      margin-right: 1rem;
      font-weight: 400;
    }
    button {
      width: 100%;
      padding: 0.8rem;
      background: #3182ce;
      color: #fff;
      border: none;
      border-radius: 6px;
      font-size: 1.1rem;
      font-weight: 700;
      cursor: pointer;
      transition: background 0.2s;
    }
    button:hover {
      background: #2563eb;
    }
    .success-message {
      color: #38a169;
      text-align: center;
      margin-top: 1rem;
      font-weight: 500;
    }
    .loader-overlay {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      background: rgba(255,255,255,0.7);
      z-index: 9999;
      align-items: center;
      justify-content: center;
    }
    .loader {
      border: 6px solid #f3f3f3;
      border-top: 6px solid #3182ce;
      border-radius: 50%;
      width: 48px;
      height: 48px;
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
</head>
<body>
  <div class="loader-overlay" id="loaderOverlay">
    <div class="loader"></div>
    <div style="margin-top:16px; text-align:center; color:#2d3748; font-weight:500;">Creating PR, please wait...</div>
  </div>
  <div class="form-container">
    <div style="text-align:center; margin-bottom:1.2rem;">
      <img src="{{ url_for('static', filename='konnect.svg') }}" alt="Kong Konnect Logo" style="max-width:180px; height:auto;"/>
    </div>
    <h2>New Onboarding Request</h2>
    <form method="post" autocomplete="off" onsubmit="document.getElementById('loaderOverlay').style.display='flex';">
      <label for="name">Team Name</label>
      <input id="name" name="name" type="text" required>
      <label for="description">Team Description</label>
      <input id="description" name="description" type="text" required>
      <label for="email">Team Email</label>
      <input id="email" name="email" type="email" required>
      <div class="checkbox-group">
        <label>Entitlements:</label><br>
        <label><input type="checkbox" name="entitlements" value="konnect.control_plane"> Control Plane</label>
        <label><input type="checkbox" name="entitlements" value="konnect.api_product"> API Product</label>
        <label><input type="checkbox" name="entitlements" value="konnect.api"> API</label>
      </div>
      <button type="submit">Submit</button>
    </form>
    {% if message %}<div class="success-message">{{ message }}</div>{% endif %}
  </div>
</body>
</html>
'''

@app.route('/', methods=['GET', 'POST'])
def onboard_team():
    message = request.args.get('message', '')
    if request.method == 'POST':
        name = request.form['name']
        description = request.form['description']
        email = request.form['email']
        entitlements = request.form.getlist('entitlements')
        # Load existing YAML
        with open(TEAMS_YAML_PATH, 'r') as f:
            data = yaml.safe_load(f)
        # Find the next TID
        import re
        import tempfile
        import shutil
        import datetime
        max_tid = 0
        for team in data.get('resources', []):
            labels = team.get('labels')
            if isinstance(labels, dict):
                tid = labels.get('TID')
                if tid:
                    m = re.match(r"KTEAM_(\d{5})", str(tid))
                    if m:
                        num = int(m.group(1))
                        if num > max_tid:
                            max_tid = num
        next_tid = f"KTEAM_{max_tid+1:05d}"

        # Add new team with TID label and entitlements
        new_team = {
            'type': 'konnect.team',
            'name': name,
            'description': description,
            'labels': {
                'TID': next_tid
            },
            'entitlements': entitlements
        }
        data['resources'].append(new_team)

        # --- GIT/PR LOGIC START ---
        import subprocess
        temp_dir = tempfile.mkdtemp()
        repo_url = "https://github.com/KongHQ-CX/kw-platform-ops.git"
        subprocess.check_call(['git', 'clone', repo_url, temp_dir])

        # Create a new branch
        branch_name = f"onboard-{name.lower().replace(' ', '-')}-{datetime.datetime.now().strftime('%Y%m%d%H%M%S')}"
        subprocess.check_call(['git', '-C', temp_dir, 'checkout', '-b', branch_name])

        # Overwrite the teams/resources.yaml file
        target_yaml = os.path.join(temp_dir, 'teams', 'resources.yaml')
        with open(target_yaml, 'w') as f:
            yaml.dump(data, f, sort_keys=False)

        # Commit and push
        subprocess.check_call(['git', '-C', temp_dir, 'add', 'teams/resources.yaml'])
        subprocess.check_call(['git', '-C', temp_dir, 'commit', '-m', f"Onboard team: {name}"])
        subprocess.check_call(['git', '-C', temp_dir, 'push', 'origin', branch_name])

        # Create PR using gh CLI
        pr_title = f"Onboard team: {name}"
        pr_body = f"Automated onboarding request for team '{name}' via webapp."
        subprocess.check_call([
            'gh', 'pr', 'create',
            '--repo', 'KongHQ-CX/kw-platform-ops',
            '--head', branch_name,
            '--base', 'main',
            '--title', pr_title,
            '--body', pr_body
        ])

        shutil.rmtree(temp_dir)
        # --- GIT/PR LOGIC END ---

        return redirect(url_for('onboard_team', message=f"PR created to onboard team '{name}'!"))
    return render_template_string(FORM_HTML, message=message)

if __name__ == '__main__':
    app.run(debug=True)
