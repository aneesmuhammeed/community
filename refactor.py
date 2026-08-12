import os
import re

files = [
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\auth\presentation\pages\login_page.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\bookings\presentation\pages\facility_booking_page.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\complaints\presentation\pages\my_complaints_page.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\complaints\presentation\pages\raise_complaint_page.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\home\presentation\pages\home_dashboard_page.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\maintenance\presentation\pages\maintenance_and_billing_page.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\profile\presentation\pages\edit_profile_page.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\profile\presentation\pages\family_members_page.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\profile\presentation\pages\notifications_settings_page.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\profile\presentation\pages\profile_page.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\profile\presentation\pages\vehicles_page.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\profile\presentation\widgets\add_family_member_modal.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\profile\presentation\widgets\add_vehicle_modal.dart",
    r"c:\Users\anees\OneDrive\Desktop\New folder (4)\lib\features\visitors\presentation\pages\visitor_invite_page.dart",
]

for filepath in files:
    if not os.path.exists(filepath):
        print(f"Not found: {filepath}")
        continue
        
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
        
    if "flutter_riverpod" not in content:
        content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n" + content
        
    if "userProvider" not in content:
        content = "import '../../../../core/providers/user_provider.dart';\n" + content
        
    # Replace global `currentUser` with `ref.read(userProvider)!` or watch?
    # It's better to just do `final currentUser = ref.watch(userProvider)!;` at the start of build
    # But some methods (like handlers) might use currentUser. So let's replace `currentUser` with `ref.read(userProvider)!`
    # or `ref.watch(userProvider)!`. Actually `currentUser` as a global might be used in init, build, or handlers.
    # To keep it simple, `currentUser` -> `ref.watch(userProvider)!` inside build, or `ref.read(userProvider)!` inside methods.
    
    # Alternatively, just replace `currentUser` with `(ref.read(userProvider) ?? ref.watch(userProvider)!)` is not valid syntax.
    
    # Just replacing:
    # class X extends StatefulWidget -> class X extends ConsumerStatefulWidget
    # class XState extends State<X> -> class XState extends ConsumerState<X>
    # class X extends StatelessWidget -> class X extends ConsumerWidget
    # Widget build(BuildContext context) -> Widget build(BuildContext context, WidgetRef ref) (only for ConsumerWidget)
    
    content = re.sub(r"extends\s+StatefulWidget", "extends ConsumerStatefulWidget", content)
    content = re.sub(r"extends\s+State<([A-Za-z0-9_]+)>", r"extends ConsumerState<\1>", content)
    
    # Fix createState return type: State<ClassName> createState() -> ConsumerState<ClassName> createState()
    content = re.sub(r"State<([A-Za-z0-9_]+)>\s+createState\(\)", r"ConsumerState<\1> createState()", content)
    
    if "ConsumerWidget" not in content and "extends StatelessWidget" in content:
        content = re.sub(r"extends\s+StatelessWidget", "extends ConsumerWidget", content)
        content = re.sub(r"Widget\s+build\(\s*BuildContext\s+context\s*\)", "Widget build(BuildContext context, WidgetRef ref)", content)
        
    # for ConsumerState, `ref` is available everywhere.
    content = re.sub(r"\bcurrentUser\b", "ref.watch(userProvider)!", content)
    
    # Fix the assignment error in login_page.dart that happens because of the blind replacement above
    content = content.replace(
        "ref.watch(userProvider)! = UserModel.fromJson(res);",
        "ref.read(userProvider.notifier).setUser(UserModel.fromJson(res));"
    )
    
    # Also fix edit_profile_page.dart assignment if it exists
    content = content.replace(
        "ref.watch(userProvider)! = ref.watch(userProvider)!.copyWith(",
        "ref.read(userProvider.notifier).setUser(ref.watch(userProvider)!.copyWith("
    )
    
    # Some widget files might have 'currentUser' imported like `import '...user_model.dart' as um;`
    content = re.sub(r"import\s+['\"].*main\.dart['\"];\s*//\s*Ensure global currentUser is imported", "", content)

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)

print("Refactoring done.")
