printf '" Vi 레거시 호환 모드 끄기 (이상한 동작 방지)\nset nocompatible\n\n" 백스페이스 키 정상 작동 보장\nset backspace=indent,eol,start\n\n" 브래킷 페이스트(Bracketed Paste) 모드 비활성화 (핵심: 자동 INSERT 진입 방지)\nset t_BE=\n' > ~/.vimrc
