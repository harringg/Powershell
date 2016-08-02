$string05 = "A;;LCRPDTLOCRSDRC;;;S-1-5-21-2443529608-3098792306-3041422421-513"
$string13 = "OA;;WP;bf967953-0de6-11d0-a285-00aa003049e2;;S-1-5-21-2443529608-3098792306-3041422421-513"

Switch ($ACETypeS) {
        "A" {$ACEType = "ACCESS ALLOWED"}
        "D" {$ACEType = "ACCESS DENIED"}
        "OA" {$ACEType = "OBJECT ACCESS ALLOWED"}
        "OD" {$ACEType = "OBJECT ACCESS DENIED"}
        "AU" {$ACEType = "SYSTEM AUDIT"}
        "AL" {$ACEType = "SYSTEM ALARM"}
        "OU" {$ACEType = "OBJECT SYSTEM AUDIT"}
        "OL" {$ACEType = "OBJECT SYSTEM ALARM"}    
    } #end Switch ACEType

Switch ($ACEFlags) {
        "CI" {$ACEFlag = "CONTAINER INHERIT"}
        "OI" {$ACEFlag = "OBJECT INHERIT"}
        "NP" {$ACEFlag = "NO PROPAGATE"}
        "IO" {$ACEFlag = "INHERITANCE ONLY"}
        "ID" {$ACEFlag = "ACE IS INHERITED"}
        "SA" {$ACEFlag = "SUCCESSFUL ACCESS AUDIT"}
        "FA" {$ACEFlag = "FAILED ACCESS AUDIT"}
    } #end Switch ACEType


Switch ($GenericAccessRights) {
        "GA" {$GenericAccessRight = "GENERIC ALL"}
        "GR" {$GenericAccessRight = "GENERIC READ"}
        "GW" {$GenericAccessRight = "GENERIC WRITE"}
        "GX" {$GenericAccessRight = "GENERIC EXECUTE"}
    } #end Switch GenericAccessRights

Switch ($DirectoryAccessRights) {
        "RC" {$DirectoryAccessRight = "Read Permissions"}
        "SD" {$DirectoryAccessRight = "Delete"}
        "WD" {$DirectoryAccessRight = "Modify Permissions"}
        "WO" {$DirectoryAccessRight = "Modify Owner"}
        "RP" {$DirectoryAccessRight = "Read All Properties"}
        "WP" {$DirectoryAccessRight = "Write All Properties"}
        "CC" {$DirectoryAccessRight = "Create All Child Objects"}
        "DC" {$DirectoryAccessRight = "Delete All Child Objects"}
        "LC" {$DirectoryAccessRight = "List Contents"}
        "SW" {$DirectoryAccessRight = "All Validated Writes"}
        "LO" {$DirectoryAccessRight = "List Object"}
        "DT" {$DirectoryAccessRight = "Delete Subtree"}
        "CR" {$DirectoryAccessRight = "All Extended Rights"}
    } #end Switch DirectoryAccessRights

Switch ($FileAccessRights) {
        "FA" {$FileAccessRight = "FILE ALL ACCESS"}
        "FR" {$FileAccessRight = "FILE GENERIC READ"}
        "FW" {$FileAccessRight = "FILE GENERIC WRITE"}
        "FX" {$FileAccessRight = "FILE GENERIC EXECUTE"}
    } #end Switch FileAccessRights

Switch ($Trustees) {
        "AO" {$Trustee = "Account operators"}
        "RU" {$Trustee = "Alias to allow previous Windows 2000"}
        "AN" {$Trustee = "Anonymous logon"}
        "AU" {$Trustee = "Authenticated users"}
        "BA" {$Trustee = "Built-in administrators"}
        "BG" {$Trustee = "Built-in guests"}
        "BO" {$Trustee = "Backup operators"}
        "BU" {$Trustee = "Built-in users"}
        "CA" {$Trustee = "Certificate server administrators"}
        "CG" {$Trustee = "Creator group"}
        "CO" {$Trustee = "Creator owner"}
        "DA" {$Trustee = "Domain administrators"}
        "DC" {$Trustee = "Domain computers"}
        "DD" {$Trustee = "Domain controllers"}
        "DG" {$Trustee = "Domain guests"}
        "DU" {$Trustee = "Domain users"}
        "EA" {$Trustee = "Enterprise administrators"}
        "ED" {$Trustee = "Enterprise domain controllers"}
        "WD" {$Trustee = "Everyone"}
        "PA" {$Trustee = "Group Policy administrators"}
        "IU" {$Trustee = "Interactively logged-on user"}
        "LA" {$Trustee = "Local administrator"}
        "LG" {$Trustee = "Local guest"}
        "LS" {$Trustee = "Local service account"}
        "SY" {$Trustee = "Local system"}
        "NU" {$Trustee = "Network logon user"}
        "NO" {$Trustee = "Network configuration operators"}
        "NS" {$Trustee = "Network service account"}
        "PO" {$Trustee = "Printer operators"}
        "PS" {$Trustee = "Personal self"}
        "PU" {$Trustee = "Power users"}
        "RS" {$Trustee = "RAS servers group"}
        "RD" {$Trustee = "Terminal server users"}
        "RE" {$Trustee = "Replicator"}
        "RC" {$Trustee = "Restricted code"}
        "SA" {$Trustee = "Schema administrators"}
        "SO" {$Trustee = "Server operators"}
        "SU" {$Trustee = "Service logon user"}
    } #end Switch Trustees