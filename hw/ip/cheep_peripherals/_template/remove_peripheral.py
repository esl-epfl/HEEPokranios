import os
import argparse
import shutil

def delete_peripheral(peripheral_name):
    # Locate the script's directory
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Path 1: The hardware folder (../<peripheral_name>)
    hw_path = os.path.abspath(os.path.join(script_dir, "..", peripheral_name))

    # Path 2: The software driver folder (../../../../sw/external/lib/drivers/<peripheral_name>)
    sw_path = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", "sw", "external", "lib", "drivers", peripheral_name))
    app_path = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", "sw", "applications", f"test_{peripheral_name}"))

    targets = [
        ("Hardware Directory", hw_path),
        ("Software Driver Directory", sw_path),
        ("Software App Directory", app_path)
    ]

    print(f"Attempting to delete peripheral: {peripheral_name}\n" + "-"*40)

    for label, path in targets:
        if os.path.exists(path):
            try:
                # Recursively delete the directory
                shutil.rmtree(path)
                print(f"🗑  Deleted {label}: {path}")
            except Exception as e:
                print(f"❌ Could not delete {label} at {path}: {e}")
        else:
            print(f"⤺  Skipped - {label} not found at: {path}")

    print("-"*40 + "\nCleanup complete.")
    print("Your peripheral might still have some tentacles 🐙 around. Check:")
    print("🔎 config/cheep-configs.py")
    print("🔎 hw/ip/cheep_top.sv.tpl")
    print("🔎 hw/ip/cheep_peripherals.sv.tpl")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Delete a peripheral's hardware and software directories.")
    parser.add_argument("peripheral_name", help="The name of the peripheral folder to delete")

    args = parser.parse_args()

    # Safety confirmation
    confirm = input(f"Are you sure you want to delete all files for '{args.peripheral_name}'? (y/n): ")
    if confirm.lower() == 'y':
        delete_peripheral(args.peripheral_name)
    else:
        print("🛑 Deletion cancelled.")