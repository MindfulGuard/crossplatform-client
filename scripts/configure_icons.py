# This script configures the icons file.

PATH_TO_ICONS_FILE_DART = "lib/view/components/icons.dart"

def main():
    with open(PATH_TO_ICONS_FILE_DART, 'r') as f:
        file = f.readlines()
    
    result = []

    for i in file:
        tmp = ""

        if "._();" in i:
            tmp = i.replace(
                "._();",
                "();"
            )
        elif "const IconData(" not in i:
            tmp = i.replace(
                "static const IconData",
                "IconData"
            ).replace(
                "IconData(",
                "const IconData("
            )
        elif "const IconData(" in i:
            tmp = i

        result.append(tmp)

    with open(PATH_TO_ICONS_FILE_DART, 'w') as f:
        f.writelines(result)

if __name__ == "__main__":
    main()