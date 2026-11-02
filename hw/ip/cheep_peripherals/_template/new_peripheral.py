import os
import shutil
import subprocess
import argparse
import datetime
from mako.template import Template

def generate_files(peripheral_name, author="Juan Sapriza"):
    # Get current year
    year = datetime.datetime.now().year

    # Define the context for the templates
    context = {
        "peripheral_name": peripheral_name,
        "peripheral_name_upper": peripheral_name.upper(),
        "year": year,
        "author": author
    }

    # Locate the script's directory and the templates
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Define the output base path: <path_to_script>/../<peripheral_name>/
    base_output_path = os.path.abspath(os.path.join(script_dir, "..","peripherals", peripheral_name))

    # Define the file generation tasks
    # Format: (template_filename, output_directory, output_filename_pattern)
    tasks = [
        ("hjson.default",   "registers", f"{peripheral_name}.hjson"),
        ("waivers.default", "waivers",   f"{peripheral_name}-waivers.vlt"),
        ("rtl.default",     "rtl",       f"{peripheral_name}.sv"),
        ("core.default",    ".",         f"{peripheral_name}.core"),
        ("c.default",       f"../../../../../sw/applications/test_{peripheral_name}",  "main.c"),
    ]

    print(f"📤 Template directory: {script_dir}")
    print(f"📥 Target directory:   {base_output_path}")

    for template_name, sub_dir, output_file in tasks:
        # Template is in the same folder as the script
        template_path = os.path.join(script_dir, template_name)

        if not os.path.exists(template_path):
            print(f"❌ Error: Template file '{template_path}' not found.")
            continue

        # Target directory is inside the new peripheral folder
        target_dir = os.path.join(base_output_path, sub_dir)
        os.makedirs(target_dir, exist_ok=True)

        try:
            # Load template from the script's directory
            mytemplate = Template(filename=template_path)
            rendered_content = mytemplate.render(**context)

            output_full_path = os.path.join(target_dir, output_file)

            with open(output_full_path, "w") as f:
                f.write(rendered_content)

            print(f"✅ Generated: {output_full_path}")

        except Exception as e:
            print(f"❌ Failed to generate {output_file}: {e}")


    sh_source = os.path.join(script_dir, "generate_registers.sh")
    sh_target_name = f"{peripheral_name}.sh"
    sh_destination = os.path.join(base_output_path, sh_target_name)

    if os.path.exists(sh_source):
        # Copy file
        shutil.copy2(sh_source, sh_destination)

        # Add execution permissions (chmod +x)
        mode = os.stat(sh_destination).st_mode
        os.chmod(sh_destination, mode | 0o111)
        print(f"✅ Copied and set execution permissions: {sh_destination}")

        # 3. Execute the script
        print(f"🏃 Running ./{sh_target_name}...")
        try:
            # Running with bash explicitly and setting cwd to the output folder
            subprocess.run(["bash", f"./{sh_target_name}"], cwd=base_output_path, check=True)
            print("✅ Successfully ran the register generation script.")
            print(f"💡 You can modify the registers/{peripheral_name}.hjson file with new registers and run")
            print(f"      source {peripheral_name}.sh \n   to update the register interface. You are then good to use the registers on your rtl/{peripheral_name}.sv")
            print("\n You should also add your peripheral in:")
            print("✍️  config/cheep_configs.py - Add it to the list of peripherals")
            print("✍️  hw/ip/cheep_peripherals/peripherals.core - Append the core file")
            print("✍️  hw/ip/cheep_peripherals.sv.tpl - Add the following:")
            print(f"{peripheral_name} u_{peripheral_name} (\n  .clk_i (system_clk),\n  .rst_ni(rst_ni),\n  .req_i ({peripheral_name}_req_i),\n  .rsp_o ({peripheral_name}_rsp_o)\n); ")
            print("and then 🏃 run mcu-gen")

        except subprocess.CalledProcessError as e:
            print(f"❌ Error: Script returned exit code {e.returncode}")
    else:
        print(f"⚠️ Warning: generate_registers.sh not found in {script_dir}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate peripheral boilerplate files.")
    parser.add_argument("peripheral_name", help="The name of the peripheral")
    parser.add_argument("--author", default="Juan Sapriza", help="Author name")

    args = parser.parse_args()
    generate_files(args.peripheral_name, args.author)