<p align="center">
<a name="top" href="http://b4b4r07.com/dotfiles"><img src="https://s18.postimg.org/tbyi5tspl/warmod.png"></a>
</p>

<p align="center">
<b><a href="#overview">Overview</a></b>
|
<b><a href="#devs">Devs</a></b>
|
<b><a href="#features">Features</a></b>
|
<b><a href="#installation">Installation</a></b>
|
<b><a href="#commands">Commands</a></b>
|
<b><a href="#testers">Testers</a></b>
|
<b><a href="#testers">Bugs</a></b>
|
<b><a href="#license">License</a></b>
</p>

## Overview

The main goal is to reproduce the Warmod BFG csgo plugin to CS2D.

<p align="right"><a href="#top">:arrow_up:</a></p>

## Devs

- **x[N]ir** 
- **Hajt**

<p align="right"><a href="#top">:arrow_up:</a></p>

## Features

- **Commands system**
- **Rage-Quit detection**
- **MVP**
- **Online statistics**

<p align="right"><a href="#top">:arrow_up:</a></p>

## Installation

1. Download the latest release from the <a href=https://github.com/codneutro/warmod/releases>**release page**</a>.
2. Extract the archive into your **cs2d root folder**.
3. Add your **admins USGNs** separated by spaces/lines into sys/lua/warmod/cfg/admins.cfg 
4. Edit the **server.cfg** located here sys/lua/warmod/cfg/server.cfg

<p align="right"><a href="#top">:arrow_up:</a></p>

## Commands

A complete list of all commands available in game.

<table>
    <thead>
        <tr>
            <th>Command</th>
            <th>Description</th>
            <th>Admin access</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><strong>!ready</strong></td>
            <td>Set yourself as ready</td>
            <td align="center">:x:</td>
        </tr>
        <tr>
            <td><strong>!notready</strong></td>
            <td>Set yourself as not ready</td>
            <td align="center">:x:</td>
        </tr>
        <tr>
            <td><strong>!bc &lt;message&gt;</strong></td>
            <td>Displays a server message</td>
            <td align="center">:white_check_mark:</td>
        </tr>
        <tr>
            <td><strong>!readyall</strong></td>
            <td>Force all players to be ready</td>
            <td align="center">:white_check_mark:</td>
        </tr>
        <tr>
            <td><strong>!cancel</strong></td>
            <td>Cancels a mix</td>
            <td align="center">:white_check_mark:</td>
        </tr>
        <tr>
            <td><strong>!whois &lt;id&gt;</strong></td>
            <td>Displays the USGN of the specified player</td>
            <td align="center">:x:</td>
        </tr>
        <tr>
            <td><strong>!mute &lt;id&gt;</strong></td>
            <td>Mutes target player</td>
            <td align="center">:white_check_mark:</td>
        </tr>
        <tr>
            <td><strong>!unmute &lt;id&gt;</strong></td>
            <td>Unmutes a previously muted player</td>
            <td align="center">:white_check_mark:</td>
        </tr>
        <tr>
            <td><strong>!teamname &lt;name&gt;</strong></td>
            <td>Changes the team name</td>
            <td align="center">:x:</td>
        </tr>
        <tr>
            <td><strong>!sub &lt;id&gt;</strong></td>
            <td>Sub request</td>
            <td align="center">:x:</td>
        </tr>
        <tr>
            <td><strong>!accept</strong></td>
            <td>Accept a sub request from a player</td>
            <td align="center">:x:</td>
        </tr>
        <tr>
            <td><strong>!nosub</strong></td>
            <td>Cancels the sub request</td>
            <td align="center">:x:</td>
        </tr>
        <tr>
            <td><strong>!map &lt;name&gt;</strong></td>
            <td>Changes the map</td>
            <td align="center">:white_check_mark:</td>
        </tr>
        <tr>
            <td><strong>!kick &lt;id&gt;</strong></td>
            <td>Kicks a player</td>
            <td align="center">:white_check_mark:</td>
        </tr>
        <tr>
            <td><strong>!ban &lt;id&gt;</strong></td>
            <td>Bans a player</td>
            <td align="center">:white_check_mark:</td>
        </tr>
        <tr>
            <td><strong>!version</strong></td>
            <td>Displays the current warmod version</td>
            <td align="center">:x:</td>
        </tr>
        <tr>
            <td><strong>!help</strong></td>
            <td>Displays the command list</td>
            <td align="center">:x:</td>
        </tr>
        <tr>
            <td><strong>!rr</strong></td>
            <td>Vote for a restart</td>
            <td align="center">:x:</td>
        </tr>
    </tbody>
</table>

<p align="right"><a href="#top">:arrow_up:</a></p>

## Testers

Big thanks to our testers !

- **Sl!m**

<p align="right"><a href="#top">:arrow_up:</a></p>

## Bugs

List of known bugs:

<p align="right"><a href="#top">:arrow_up:</a></p>

## License

Copyright 2016 x[N]ir

Licensed under the Apache License, Version 2.0 (the "License");<br>
you may not use this file except in compliance with the License.<br>
You may obtain a copy of the License at<br><br>
       http://www.apache.org/licenses/LICENSE-2.0<br><br>
Unless required by applicable law or agreed to in writing, software<br>
distributed under the License is distributed on an "AS IS" BASIS,<br>
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.<br>
See the License for the specific language governing permissions and<br>
limitations under the License.<br>

<p align="right"><a href="#top">:arrow_up:</a></p>
