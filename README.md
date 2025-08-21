# Generators - By [Zero Config Rails](https://zeroconfigrails.com/)

[![Ruby](https://img.shields.io/badge/Ruby-3.2+-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0+-red.svg)](https://rubyonrails.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Generators** is an interactive web application that helps Rails developers discover, configure, and install Ruby gems in a single command. It also provides user-friendly interface for `rails new` with pre-configured configurations straight from the Rails guide/manual. Future additions will also include other Rails default generators for Scaffold, Model, Controller, etc..

## Requirements

- Ruby 3.4.5
- Rails 8.0
- PostgreSQL
- Node.js 20.15.1 and Yarn
- TailwindCSS 4 and Daisy UI

## Installation

1. **Clone the repository**
   ```bash
   git clone git@github.com:Zero-Config-Rails/generators.git
   cd generators
   ```

2. **Install dependencies and setup the database**
   ```bash
   bin/setup
   ```

3. **Start the development server**
   ```bash
   bin/dev
   ```

4. **Visit the application**
   Open [http://localhost:3000](http://localhost:3000) in your browser

## 🏗️ Architecture

### Core Models

- **Generator**: Represents a Rails generator with metadata and configurations
- **Configuration**: Individual configuration options for generators
- **Field Types**: Polymorphic field types (TextField, DropdownField, BooleanField) using [Single Table Inheritance](https://guides.rubyonrails.org/association_basics.html#single-table-inheritance-sti)

### Key Components

- **Boring Generators**: Base from where Gem generators are derived
- **Default Rails Generators**: Auto-generated configurations from `rails new --help` using a rake task `rake rails_new:parse_options`

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 🐛 Bug Reports

Please use the [GitHub issue tracker](https://github.com/Zero-Config-Rails/generators/issues) to report bugs or request features.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Rails](https://rubyonrails.org/) - The web framework that makes it all possible
- [Boring Generators](https://github.com/abhaynikam/boring_generators) - The generator ecosystem
- [Avo](https://avohq.io/) - Beautiful admin panel framework
- [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS framework

---

**Made with ❤️ by the [Zero Config Rails team](https://zeroconfigrails.com/)**
