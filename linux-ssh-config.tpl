cat << EOF >> ~/.ssh/config
    Host $(hostname)
        Hostname $(hostname)
        user $(user)
        IdentityFile $(identityfile)
    EOF

    