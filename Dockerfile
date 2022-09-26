FROM ubuntu:20.04

USER root

# Install requirements for adding PPAs
RUN apt-get update
RUN apt-get install gnupg software-properties-common apt-transport-https ca-certificates -y

# Add PPA for kr
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C4A05888A1C4FA02E1566F859F2A29A569653940
RUN add-apt-repository "deb http://kryptco.github.io/deb kryptco main"

# Install packages we don't care about versions of
RUN apt-get update
RUN apt-get install -y tmux curl zsh git build-essential curl libffi-dev libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5 dirmngr apt-transport-https kr wget openssh-client

RUN git config --global commit.gpgsign true
RUN git config --global gpg.program /usr/bin/krgpg

# Install recent neovim
RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.deb && apt-get install ./nvim-linux64.deb

# Install terraform lsp
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt-get update
RUN apt-get install terraform-ls -y

RUN useradd -ms /usr/bin/zsh dev
USER dev

# Install ohmyzsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN echo "export GPG_TTY=$(tty)" >> ~/.zshrc

RUN mkdir /home/dev/code
WORKDIR /home/dev/code

RUN git clone https://github.com/samisagit/dot-files.git ~/dot-files
RUN cd ~/dot-files && git remote set-url origin git@github.com:samisagit/dot-files.git && cd -

RUN git config --global user.name "samisagit"
RUN git config --global user.email "sam@whiteteam.co.uk"

RUN ln -s ~/dot-files/.config ~/.config

RUN nvim --headless +PlugInstall +qall

ENTRYPOINT [ "nvim", "." ]
